import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/showShackbar.dart';
import 'package:vk_parse/models/Song.dart';

enum DownloadState { COMPLETED, ERROR, STARTED, STOPPED, EMPTY, EXIST }

class MusicDownloadData with ChangeNotifier {
  List<Song> _query = [];
  Song currentSong;
  double progress = 0;
  StreamSubscription _downloadSubscription;

  final StreamController<DownloadState> _resultController =
      StreamController<DownloadState>.broadcast();
  final StreamController<List<Song>> _queryController =
      StreamController<List<Song>>.broadcast();

  set _state(DownloadState state) {
    _resultController.add(state);
  }

  set query(Song song) {
    _query.add(song);
    _queryController.add(_query);
  }

  set multiQuery(List<Song> songList) {
    _query.addAll(songList);
    _queryController.add(_query);
  }

  MusicDownloadData() {
    _state = DownloadState.COMPLETED;
  }

  downloadSingle(Song song) async {
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
          response.asStream().listen((http.StreamedResponse r) {
        r.stream.listen((List<int> chunk) {
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

  Stream<List<Song>> get onQueryChanged => _queryController.stream;

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
    _resultController?.close();
    super.dispose();
  }
}
