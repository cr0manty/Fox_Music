import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/utils/closable_http_requuest.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:fox_music/api/music_list.dart';
import 'package:fox_music/functions/format/song_name.dart';

import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/functions/utils/snackbar.dart';
import 'package:fox_music/models/song.dart';

enum DownloadState { COMPLETED, ERROR, STARTED, STOPPED, EMPTY, EXIST }

class MusicDownloadData with ChangeNotifier {
  List<Song> _query = [];
  List<Song> dataSong = [];
  Song currentSong;
  double progress = 0;
  DownloadState _downloadState;
  StreamSubscription _downloadSubscription;
  StreamSubscription _queryChange;
  StreamSubscription _stateChange;
  MusicData musicData;
  CloseableMultipartRequest httpClient;
  bool _isCanceled = false;
  Timer _timer;

  final StreamController<DownloadState> _resultController =
      StreamController<DownloadState>.broadcast();
  final StreamController<Song> _queryController =
      StreamController<Song>.broadcast();

  set _state(DownloadState state) {
    _resultController.add(state);
  }

  set query(Song song) {
    _queryController.add(song);
    notifyListeners();
  }

  set multiQuery(List<Song> songList) {
    songList.forEach((Song song) {
      _queryController.add(song);
    });
    notifyListeners();
  }

  MusicDownloadData() {
    _downloadState = DownloadState.COMPLETED;
  }

  init(MusicData data) {
    musicData = data;
    loadMusic();

    _queryChange = onQueryChanged.listen((Song song) {
      _query.add(song);
      _prosesDownloadQuery();
    });

    _stateChange = onResultChanged.listen((DownloadState state) {
      _downloadState = state;
      if (state == DownloadState.COMPLETED) {
        _prosesDownloadQuery();
      }
    });
  }

  inQuery(Song song) {
    return _query.indexOf(song) != -1;
  }

  _prosesDownloadQuery() async {
    if (_downloadState != DownloadState.STARTED && _query.length > 0) {
      await downloadSong(_query[0]).then((res) async {
        await _query.removeAt(0);
      });
    }
  }

  deleteFromQuery(Song song) {
    _query.remove(song);
    notifyListeners();
  }

  bool checkLocal(Song song) {
    return musicData.localSongs.indexOf(song) != -1;
  }

  void loadDownloaded(List<Song> songs) {
    dataSong.clear();
    songs.forEach((song) {
      song.downloaded = musicData.localSongs.indexOf(song) != -1;
      dataSong.add(song);
    });
  }

  loadMusic() async {
    List<Song> songs = await musicListGet();
    await loadDownloaded(songs);

    notifyListeners();
  }

  cancelDownload() {
    if (currentSong != null && httpClient != null) {
      currentSong = null;
      progress = 0;
      _isCanceled = true;
      _timer.cancel();

      _state = DownloadState.COMPLETED;
      _downloadSubscription?.cancel();
      httpClient?.close();
      httpClient = null;
    }
    notifyListeners();
  }

  void downloadMark(Song song, {bool downloaded = true}) {
    dataSong[dataSong.indexOf(song)].downloaded = downloaded;
  }

  downloadSong(Song song) async {
    if (song.download.isEmpty) {
      _state = DownloadState.EMPTY;
    }
    List<List<int>> chunks = new List();
    currentSong = song;
    int downloaded = 0;

    httpClient = CloseableMultipartRequest('GET', Uri.parse(song.download));
    var response = httpClient.send();
    _state = DownloadState.STARTED;
    notifyListeners();

    _downloadSubscription =
        await response.asStream().listen((http.StreamedResponse r) async {
      r.stream.listen((List<int> chunk) {
        progress = downloaded / r.contentLength;
        chunks.add(chunk);
        downloaded += chunk.length;
        _timer = Timer.periodic(
            Duration(milliseconds: (r.contentLength / 50000).round()), (timer) {
          if (httpClient == null || progress == 0) {
            timer.cancel();
            _timer.cancel();
          } else {
            notifyListeners();
          }
        });
      }, onDone: () async {
        final Uint8List bytes = Uint8List(r.contentLength);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        if (!_isCanceled) {
          await saveSong(song, bytes);
          _state = DownloadState.COMPLETED;
          _timer.cancel();
          downloadMark(currentSong);
          currentSong = null;
          httpClient = null;
          progress = 0;
          notifyListeners();
        }
        _isCanceled = false;
        _downloadSubscription?.cancel();
      }, onError: (error) {
        _downloadSubscription?.cancel();
        httpClient = null;
        progress = 0;
        currentSong = null;
        _state = DownloadState.ERROR;
        _query.remove(song);

        notifyListeners();
      });
    });
  }

  addToQuery(Song song) async {
    if (song?.download == null || song.download.isEmpty) {
      _state = DownloadState.EMPTY;
      notifyListeners();
    } else if ((await _songExist(song)) != null) {
      query = song;
    }
  }

  addToQueryMulti(List<Song> songList) {
    songList.forEach((Song song) async {
      if ((await _songExist(song)) != null) {
        _query.add(song);
      }
    });
  }

  Stream<DownloadState> get onResultChanged => _resultController.stream;

  Stream<Song> get onQueryChanged => _queryController.stream;

  downloadMulti(BuildContext context, List<Song> songList) async {}

  saveSong(Song song, Uint8List bytes) async {
    File file = await _songExist(song);
    if (file != null) {
      await file.writeAsBytes(bytes);

      musicData.loadSavedMusic();
      musicData.localUpdate = true;
      return true;
    }
    return false;
  }

  _songExist(Song song) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filename = await formatFileName(song);
    File file = new File('$dir/songs/$filename');

    if (!await file.exists()) return file;
    _state = DownloadState.EXIST;
    if (currentSong == song) {
      currentSong = null;
      progress = 0;
    }
    return null;
  }

  showInfo(BuildContext context, DownloadState result) {
    if (context != null) {
      switch (result) {
        case DownloadState.EMPTY:
          infoDialog(context, 'Error', 'Empty download url');
          break;
        case DownloadState.COMPLETED:
          showSnackBar(context, 'Song downloaded');
          break;
        case DownloadState.ERROR:
          showSnackBar(context, 'Smth went wrong...');
          break;
        case DownloadState.EXIST:
          infoDialog(context, 'Error', 'Song alredy downloaded');
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    _queryChange?.cancel();
    _stateChange?.cancel();

    _resultController?.close();
    _queryController?.close();
    super.dispose();
  }
}
