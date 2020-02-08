import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/askDialog.dart';

class MusicListSaved extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MusicListSavedState();
}

enum ButtonState { SHARE, DELETE }

class MusicListSavedState extends State<MusicListSaved> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Song> _songData = [];

  MusicListSavedState() {
    _checkDirectory();
  }

  _checkDirectory() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _data = Provider.of<ProjectData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: Text('Media'), centerTitle: true),
        body: new ListView(
          children: _buildList(_data),
        ));
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
      final song = formatSong(songPath.path);
      if (song != null) songData.add(song);
    });
    if (mounted && songData != null) {
      setState(() {
        _songData = songData;
      });
    }
  }

  _deleteSong(Song song) {
    askDialog(_scaffoldKey.currentContext, 'Delete',
        'Are you sure you want to delete this file?', 'Delete', 'Cancel', () {
      try {
        if (mounted) {
          File(song.path).deleteSync();
          setState(() {
            _songData.remove(song);
          });
          infoDialog(_scaffoldKey.currentContext, 'File deleted',
              'Song ${song.artist} - ${song.title} successfully deleted');
        }
      } catch (e) {
        print(e);
        infoDialog(_scaffoldKey.currentContext, 'File deleted error',
            'Something went wrong while deleting the file');
      }
    });
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

  _buildList(ProjectData data) {
    if (_songData == null) {
      return null;
    }
    return _songData
        .map((Song song) => ListTile(
            title: Text(song.title),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new Text(formatTime(song.duration)),
                ),
                Container(
                    child: PopupMenuButton<ButtonState>(
                  onSelected: (ButtonState result) {
                    switch (result) {
                      case ButtonState.DELETE:
                        _deleteSong(song);
                        break;
                      case ButtonState.SHARE:
                        _shareSong(song);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<ButtonState>>[
                    const PopupMenuItem<ButtonState>(
                      value: ButtonState.SHARE,
                      child: Text('Share'),
                    ),
                    const PopupMenuItem<ButtonState>(
                      value: ButtonState.DELETE,
                      child: Text('Delete'),
                    ),
                  ],
                ))
              ],
            ),
            leading: IconButton(
                onPressed: () async {
                  int stopped = -1;
                  if (data.audioPlayer.state == AudioPlayerState.PLAYING) {
                    if (data.currentSong.song_id == song.song_id) {
                      await data.playerPause();
                    } else {
                      await data.playerStop();
                    }
                    stopped = data.currentSong.song_id;
                    if (mounted) {
                      data.setPlayedSong(null);
                    }
                  }
                  if ((data.audioPlayer.state == AudioPlayerState.PAUSED ||
                          data.audioPlayer.state == AudioPlayerState.STOPPED) &&
                      data.currentSong != null &&
                      song.song_id == data.currentSong.song_id) {
                    data.playerResume();
                  } else if (data.audioPlayer.state !=
                          AudioPlayerState.PLAYING &&
                      stopped != song.song_id) {
                    await data.playerPlay(song.path, isLocal: true);
                    if (mounted) {
                      data.setPlayedSong(song);
                    }
                  }
                },
                icon: Icon(
                  data.audioPlayer.state == AudioPlayerState.PLAYING &&
                          data.currentSong != null &&
                          data.currentSong.song_id == song.song_id
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
