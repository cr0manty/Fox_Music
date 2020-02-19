import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/showShackbar.dart';
import 'package:vk_parse/models/Song.dart';

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

  final StreamController<DownloadState> _resultController =
      StreamController<DownloadState>.broadcast();
  final StreamController<Song> _queryController =
      StreamController<Song>.broadcast();

  set _state(DownloadState state) {
    _resultController.add(state);
  }

  set query(Song song) {
    _queryController.add(song);
  }

  set multiQuery(List<Song> songList) {
    songList.forEach((Song song) {
      _queryController.add(song);
    });
  }

  MusicDownloadData() {
    _downloadState = DownloadState.COMPLETED;
  }

  init() {
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

  loadMusic() async {
    dataSong = await musicListGet();
    notifyListeners();
  }

  downloadSong(Song song) async {
    if (song.download.isEmpty) {
      _state = DownloadState.EMPTY;
    } else if ((await _songExist(song)) != null) {
      List<List<int>> chunks = new List();
      currentSong = song;
      int downloaded = 0;

      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(song.download));
      var response = httpClient.send(request);
      _state = DownloadState.STARTED;
      notifyListeners();

      _downloadSubscription =
          await response.asStream().listen((http.StreamedResponse r) async {
        await r.stream.listen((List<int> chunk) {
          progress = downloaded / r.contentLength;
          chunks.add(chunk);
          downloaded += chunk.length;
          notifyListeners();
        }, onDone: () async {
          final Uint8List bytes = Uint8List(r.contentLength);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }

          await saveSong(song, bytes);
          _state = DownloadState.COMPLETED;

          currentSong = null;
          progress = 0;

          notifyListeners();
        }, onError: (error) {
          progress = 0;
          currentSong = null;
          _state = DownloadState.ERROR;
          notifyListeners();
        });
      });
    }
  }

  addToQuery(Song song) async {
    _query.add(song);
  }

  addToQueryMulti(List<Song> songList) async {
    _query.addAll(songList);
  }

  Stream<DownloadState> get onResultChanged => _resultController.stream;

  Stream<Song> get onQueryChanged => _queryController.stream;

  downloadMulti(BuildContext context, List<Song> songList) async {}

  saveSong(Song song, Uint8List bytes) async {
    try {
      File file = await _songExist(song);
      if (file != null) await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<File> _songExist(Song song) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filename = await formatFileName(song);
    File file = new File('$dir/songs/$filename');

    if (!(await file.exists())) return file;
    _state = DownloadState.EXIST;
    return null;
  }

  showInfo(BuildContext context, DownloadState result) {
    if (context != null) {
      switch (result) {
        case DownloadState.EMPTY:
          showSnackBar(context, 'Empty download url');
          break;
        case DownloadState.COMPLETED:
          showSnackBar(context, 'Song downloaded!');
          break;
        case DownloadState.ERROR:
          showSnackBar(context, 'Smth went wrong...');
          break;
        case DownloadState.EXIST:
          infoDialog(context, 'Error', 'Song alredy downloaded!');
          currentSong = null;
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
