import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/askDialog.dart';
import 'package:vk_parse/functions/save/savePlayedSong.dart';
import 'package:vk_parse/functions/get/getPlayedSong.dart';

class MusicListSaved extends StatefulWidget {
  final AudioPlayer _audioPlayer;

  MusicListSaved(this._audioPlayer);

  @override
  State<StatefulWidget> createState() => MusicListSavedState(_audioPlayer);
}

enum ButtonState { SHARE, DELETE }

class MusicListSavedState extends State<MusicListSaved> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Song> _data = [];
  final AudioPlayer _audioPlayer;
  int nowPlayingSongId = -1;
  Song playedSong;

  MusicListSavedState(this._audioPlayer) {
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
    return new ListView(
      key: _scaffoldKey,
      children: _buildList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _setPlayedSong();
    _loadSongs();
  }

  _setPlayedSong() async {
    playedSong = await getPlayedSong();
  }

  _loadSongs() async {
    List<Song> songData = [];
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final fileList = Directory("$directory/songs/").listSync();
    fileList.forEach((songPath) {
      final song = formatSong(songPath.path);
      if (song != null) songData.add(song);
    });
    if (songData != null) {
      setState(() {
        _data = songData;
      });
    }
  }

  _deleteSong(Song song) {
    askDialog(_scaffoldKey.currentContext, 'Delete',
        'Are you sure you want to delete this file?', 'Delete', 'Cancel', () {
      try {
        File(song.path).deleteSync();
        setState(() {
          _data.remove(song);
        });
        infoDialog(_scaffoldKey.currentContext, 'File deleted',
            'Song ${song.artist} - ${song.title} successfully deleted');
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

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }
    return _data
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
                  if (_audioPlayer.state == AudioPlayerState.PLAYING) {
                    if (playedSong.song_id == song.song_id) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.stop();
                    }
                    stopped = playedSong.song_id;
                    setState(() {
                      playedSong = null;
                    });
                  }
                  if (_audioPlayer.state == AudioPlayerState.PAUSED &&
                      playedSong != null &&
                      song.song_id == playedSong.song_id) {
                    _audioPlayer.resume();
                  } else if (_audioPlayer.state != AudioPlayerState.PLAYING &&
                      stopped != song.song_id) {
                    await _audioPlayer.play(song.path, isLocal: true);
                    await savePlayedSong(song);
                    setState(() {
                      playedSong = song;
                    });
                  }
                },
                icon: Icon(
                  _audioPlayer.state == AudioPlayerState.PLAYING &&
                          playedSong != null &&
                          playedSong.song_id == song.song_id
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
