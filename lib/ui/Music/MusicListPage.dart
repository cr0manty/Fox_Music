import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/MusicData.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

enum ButtonState { SHARE, DELETE }
enum PageType { MAIN, PLAYLIST }

class MusicListPage extends StatefulWidget {
  final List<Song> _musicList;
  PageType _pageType;
  Playlist playlist;

  MusicListPage(this._musicList, {this.playlist}) {
    _pageType = playlist != null ? PageType.PLAYLIST : PageType.MAIN;
  }

  @override
  State<StatefulWidget> createState() => MusicListPageState();
}

class MusicListPageState extends State<MusicListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _addTrackToPlaylistDialog() {}

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<MusicData>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text(widget._pageType == PageType.PLAYLIST
                ? widget.playlist.title
                : 'Media'),
            actions: widget._pageType == PageType.PLAYLIST
                ? [
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addTrackToPlaylistDialog)
                  ]
                : null,
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
    showDialog(
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
                title: Text('Delete file'),
                content: Text('Are you sure you want to delete this file?'),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      isDestructiveAction: true,
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.pop(context);
                        try {
                          File(song.path).deleteSync();
                          setState(() {
                            widget._musicList.remove(song);
                          });
                          infoDialog(
                              _scaffoldKey.currentContext,
                              'File deleted',
                              'Song ${song.artist} - ${song.title} successfully deleted');
                        } catch (e) {
                          print(e);
                          infoDialog(
                              _scaffoldKey.currentContext,
                              'File deleted error',
                              'Something went wrong while deleting the file');
                        }
                      })
                ]));
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

  _buildSongListTile(int index, MusicData sharedData) {
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
              if (sharedData.currentSong.song_id == song.song_id) {
                await sharedData.playerPause();
                stopped = true;
              } else {
                await sharedData.playerStop();
              }
            }
            if (sharedData.playerState != AudioPlayerState.PLAYING &&
                !stopped) {
              await sharedData.playerPlay(song);
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
