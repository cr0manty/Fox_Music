import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
    final sharedData = Provider.of<ProjectData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: Text('Media'), centerTitle: true),
        body: new ListView.separated(
          separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Divider(
                color: Colors.grey,
                height: 1,
              )),
          itemCount: _songData.length,
          itemBuilder: (context, index) =>
              _buildSongListTile(index, sharedData),
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

  _buildSongListTile(int index, ProjectData sharedData) {
    Song song = _songData[index];
    if (song == null) {
      return null;
    }
    return new Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: new Container(
          child: ListTile(
        contentPadding: EdgeInsets.only(left: 30, right: 20),
        title: Text(song.title,
            style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        subtitle: Text(song.artist,
            style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
        onTap: () async {
          if (sharedData.audioPlayer.state == AudioPlayerState.PLAYING) {
            if (sharedData.currentSong.song_id == song.song_id) {
              await sharedData.playerPause();
            } else {
              await sharedData.playerStop();
            }
          }
          if (sharedData.audioPlayer.state != AudioPlayerState.PLAYING) {
            sharedData.playerPlay(song.path);
            sharedData.setPlayedSong(song);
          }
        },
        trailing: Text(formatDuration(song.duration),
            style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
      )),
      actions: <Widget>[
        new IconSlideAction(
          caption: 'Share',
          color: Colors.indigo,
          icon: Icons.share,
          onTap: () => _shareSong(song),
        ),
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _deleteSong(song),
        ),
      ],
    );
  }
}
