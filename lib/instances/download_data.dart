import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fox_music/utils/closable_http_requuest.dart';
import 'package:fox_music/utils/help.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/models/song.dart';

import 'api.dart';
import 'check_connection.dart';
import 'music_data.dart';

enum DownloadState { COMPLETED, ERROR, STARTED, STOPPED, EMPTY, EXIST }

class MusicDownloadData {
  MusicDownloadData._internal();

  List<Song> _query = [];
  List<Song> dataSong = [];
  Song currentSong;
  double progress = 0;
  DownloadState _downloadState;
  StreamSubscription _downloadSubscription;
  StreamSubscription _queryChange;
  StreamSubscription _stateChange;
  CloseableMultipartRequest httpClient;
  bool _isCanceled = false;
  Timer _timer;

  final StreamController<DownloadState> _resultController =
      StreamController<DownloadState>.broadcast();
  final StreamController<Song> _queryController =
      StreamController<Song>.broadcast();
  final StreamController<bool> _notifyStream =
      StreamController<bool>.broadcast();
  final StreamController<bool> _filesystemStream =
      StreamController<bool>.broadcast();

  Stream<bool> get filesystemStream => _filesystemStream.stream;

  Stream<bool> get notifyStream => _notifyStream.stream;

  Stream<DownloadState> get onResultChanged => _resultController.stream;

  Stream<Song> get onQueryChanged => _queryController.stream;

  set _state(DownloadState state) {
    _resultController.add(state);
  }

  set query(Song song) {
    _queryController.add(song);
    _notifyStream.add(true);
  }

  set multiQuery(List<Song> songList) {
    songList.forEach((Song song) {
      _queryController.add(song);
    });
    _notifyStream.add(true);
  }

  static final MusicDownloadData _instance = MusicDownloadData._internal();

  static MusicDownloadData get instance => _instance;

  MusicDownloadData() {
    _downloadState = DownloadState.COMPLETED;
  }

  init() async {
    if (ConnectionsCheck.instance.isOnline) loadMusic();

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
    _notifyStream.add(true);
  }

  bool checkLocal(Song song) {
    return MusicData.instance.localSongs.indexOf(song) != -1;
  }

  void loadDownloaded(List songs) {
    if (songs != null) {
      dataSong.clear();
      songs.forEach((song) {
        song.downloaded = MusicData.instance.localSongs.indexOf(song) != -1;
        dataSong.add(song);
      });
    }
  }

  loadMusic({int page = -1}) async {
    List songs = await Api.musicListGet(page: page);
    loadDownloaded(songs);

    _notifyStream.add(true);
  }

  updateVKMusic(context, {int page = -1}) async {
    bool request = await Api.musicListPost(page: page);
    if (request) {
      HelpTools.infoDialog(context, 'Success', 'Your songs will appear soon');
    } else {
      HelpTools.infoDialog(context, 'Error', 'Smth went wrong...');
    }
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
    _notifyStream.add(true);
  }

  void downloadMark(Song song, {bool downloaded = true}) {
    dataSong[dataSong.indexOf(song)].downloaded = downloaded;
  }

  downloadSong(Song song) async {
    if (song.download.isEmpty) {
      _state = DownloadState.EMPTY;
    }
    List<List<int>> chunks = List();
    currentSong = song;
    int downloaded = 0;

    httpClient = CloseableMultipartRequest('GET', Uri.parse(song.download));
    var response = httpClient.send();
    _state = DownloadState.STARTED;
    _notifyStream.add(true);

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
            _notifyStream.add(true);
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
          _notifyStream.add(true);
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

        _notifyStream.add(true);
      });
    });
  }

  addToQuery(Song song) async {
    if (song?.download == null || song.download.isEmpty) {
      _state = DownloadState.EMPTY;
      _notifyStream.add(true);
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

  downloadMulti(context, List<Song> songList) async {}

  saveSong(Song song, Uint8List bytes) async {
    File file = await _songExist(song);
    if (file != null) {
      await file.writeAsBytes(bytes);

      MusicData.instance.loadSavedMusic();
      MusicData.instance.localUpdate = true;
      return true;
    }
    return false;
  }

  _songExist(Song song) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filename =
        song.formatFileName(MusicData.instance.localSongs.length + 1);
    File file = File('$dir/songs/$filename');

    if (!await file.exists()) return file;
    _state = DownloadState.EXIST;
    if (currentSong == song) {
      currentSong = null;
      progress = 0;
    }
    return null;
  }

  showInfo(context, DownloadState result) {
    if (context != null) {
      switch (result) {
        case DownloadState.EMPTY:
          HelpTools.infoDialog(context, 'Error', 'Empty download url');
          break;
        case DownloadState.COMPLETED:
          _notifyStream.add(true);
          _filesystemStream.add(true);
          break;
        case DownloadState.ERROR:
          HelpTools.infoDialog(context, 'Error', 'Smth went wrong...');
          break;
        case DownloadState.EXIST:
          HelpTools.infoDialog(context, 'Error', 'Song alredy downloaded');
          break;
        default:
          break;
      }
    }
  }

  void dispose() {
    _downloadSubscription?.cancel();
    _queryChange?.cancel();
    _stateChange?.cancel();
    _notifyStream?.close();
    _resultController?.close();
    _queryController?.close();
  }
}
