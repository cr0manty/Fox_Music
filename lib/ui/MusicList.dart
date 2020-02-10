import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/askDialog.dart';

enum ButtonState { SHARE, DELETE }

class MusicList extends StatefulWidget {
  final List<Song> _musicList;
  String title;

  MusicList(this._musicList, {this.title});

  @override
  State<StatefulWidget> createState() => MusicListState();
}

class MusicListState extends State<MusicList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<ProjectData>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text(widget.title != null ? widget.title : 'Media'),
            centerTitle: true),
        body: ListView.builder(
          itemCount: widget._musicList.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _buildSongListTile(index, sharedData),
        ));
  }

  _deleteSong(Song song) {
    askDialog(_scaffoldKey.currentContext, 'Delete',
        'Are you sure you want to delete this file?', 'Delete', 'Cancel', () {
      try {
        if (mounted) {
          File(song.path).deleteSync();
          setState(() {
            widget._musicList.remove(song);
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

  _renameSong(String artist, String title) {}

  _renameSongDialog(Song song) async {
    final TextEditingController artistFilter = new TextEditingController();
    final TextEditingController titleFilter = new TextEditingController();

    artistFilter.text = song.artist;
    titleFilter.text = song.title;

    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Rename'),
          content: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(children: <Widget>[
                    CupertinoTextField(
                      controller: artistFilter,
                    ),
                    Divider(height: 5, color: Colors.transparent),
                    CupertinoTextField(
                      controller: titleFilter,
                    ),
                  ]))),
          actions: <Widget>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Rename"),
                onPressed: () {
                  if (artistFilter.text.isNotEmpty &&
                      titleFilter.text.isNotEmpty) {
                    _renameSong(artistFilter.text, titleFilter.text);
                  }
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
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
    Song song = widget._musicList[index];
    if (song == null) {
      return null;
    }
    return Column(children: <Widget>[
      Slidable(
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
            bool stopped = false;
            if (sharedData.playerState == AudioPlayerState.PLAYING) {
              stopped = true;
              if (sharedData.currentSong.song_id == song.song_id) {
                await sharedData.playerPause();
              } else {
                await sharedData.playerStop();
              }
            }
            if (sharedData.playerState != AudioPlayerState.PLAYING &&
                !stopped) {
              sharedData.playerPlay(song);
            }
          },
          trailing: Text(formatDuration(song.duration),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Add to playlist',
            color: Colors.pinkAccent,
            icon: Icons.playlist_add,
            onTap: null,
          ),
          new IconSlideAction(
            caption: 'Rename',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () => _renameSongDialog(song),
          ),
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Share',
            color: Colors.indigo,
            icon: Icons.share,
            onTap: () => _shareSong(song),
          ),
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _deleteSong(song),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
