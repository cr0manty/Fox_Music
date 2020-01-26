import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'package:vk_parse/models/Song.dart';

class PlaylistPage extends StatefulWidget {
  final AudioPlayer _audioPlayer;

  PlaylistPage(this._audioPlayer);

  @override
  State<StatefulWidget> createState() => PlaylistPageState(_audioPlayer);
}

enum ButtonState { SHARE, DELETE }

class PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Song> _data = [];
  final AudioPlayer _audioPlayer;
  int nowPlayingSongId = -1;
  Song playedSong;

  PlaylistPageState(this._audioPlayer) {
    _checkDirectory();
  }

  _checkDirectory() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/playylists/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: Text('Playlists'), centerTitle: true),
        backgroundColor: Color.fromRGBO(35, 35, 35, 1),
        body: new ListView(
          children: null,
        ));
  }

  @override
  void initState() {
    super.initState();
  }


  _shareSong(Song song) async {
    final File bytes = await File(song.path);
    await WcFlutterShare.share(
        sharePopupTitle: 'Share',
        fileName:
            '${song.artist}-${song.title}-${song.duration}-${song.song_id}.mp3',
        mimeType: 'song/mp3',
        bytesOfFile: bytes.readAsBytesSync());
  }

}
