import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/askDialog.dart';

class MusicListSaved extends StatefulWidget {
  final AudioPlayer _audioPlayer;

  MusicListSaved(this._audioPlayer);

  @override
  State<StatefulWidget> createState() => MusicListSavedState(_audioPlayer);
}

class MusicListSavedState extends State<MusicListSaved> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//  AudioPlayer _audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');

  List<Song> _data = [];
  final AudioPlayer _audioPlayer;

  MusicListSavedState(this._audioPlayer);

  @override
  Widget build(BuildContext context) {
    return new ListView(
      key: _scaffoldKey,
      children: _buildList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
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
                  if (_audioPlayer.state == AudioPlayerState.PLAYING) {
                    _audioPlayer.stop();
                  }
                  _audioPlayer.play(song.path, isLocal: true);
                  setState(() {
                    song.isPlaying = !song.isPlaying;
                  });
                },
                icon: Icon(
                  song.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
