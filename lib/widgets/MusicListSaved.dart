import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/playSong.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/askDialog.dart';

class MusicListSaved extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListSavedState();
  }
}

class MusicListSavedState extends State<MusicListSaved> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Song> _data = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: new ListView(
          key: _scaffoldKey,
          children: _buildList(),
        ),
        inAsyncCall: _loading);
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  _setUpdatingStatus() {
    setState(() {
      _loading = !_loading;
    });
  }

  _loadSongs() async {
    List<Song> songData = [];
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final fileList = Directory("$directory/songs/").listSync();
    fileList.forEach((songPath) {
      songData.add(formatSong(songPath.path));
    });
    if (songData != null) {
      setState(() {
        _data = songData;
      });
    }
  }

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }
    return _data
        .map((Song song) => ListTile(
            title: Text(song.name),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new Text(formatTime(song.duration)),
                ),
                Container(
                  child: new IconButton(
                    onPressed: () {
                      askDialog(
                          _scaffoldKey.currentContext,
                          'Delete',
                          'Are you sure you want to delete this file?',
                          'Yes',
                          'Cancel', () {
                        try {
                          File(song.path).deleteSync();
                          setState(() {
                            _data.remove(song);
                          });
                          infoDialog(
                              _scaffoldKey.currentContext,
                              'File deleted',
                              'Song ${song.artist} - ${song.name} successfully deleted');
                        } catch (e) {
                          print(e);
                          infoDialog(
                              _scaffoldKey.currentContext,
                              'File deleted error',
                              'Something went wrong while deleting the file');
                        }
                      });
                    },
                    icon: Icon(Icons.more_vert,
                        size: 30, color: Color.fromRGBO(100, 100, 100, 1)),
                  ),
                )
              ],
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                  playSong(song.path);
                },
                icon: Icon(
                  Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
