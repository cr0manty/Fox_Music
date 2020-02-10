import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:vk_parse/models/Song.dart';

enum ButtonState { SHARE, DELETE }

class PlaylistPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PlaylistPage() {
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
        final _data = Provider.of<ProjectData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: Text('Playlists'), centerTitle: true),
        body: new ListView(
          children: [],
        ));
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
