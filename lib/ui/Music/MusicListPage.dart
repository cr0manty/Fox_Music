import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:vk_parse/utils/testDownload.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/provider/MusicData.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';

enum ButtonState { SHARE, DELETE }
enum PageType { SAVED, PLAYLIST }

class MusicListPage extends StatefulWidget {
  PageType _pageType;
  Playlist playlist;

  MusicListPage({this.playlist}) {
    _pageType = playlist != null ? PageType.PLAYLIST : PageType.SAVED;
  }

  @override
  State<StatefulWidget> createState() => MusicListPageState();
}

class MusicListPageState extends State<MusicListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  List<Song> _musicList = [];
  bool init = true;

  _addTrackToPlaylistDialog() {}

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    if (init) {
      init = false;
      _loadPlaylist(musicData, null);
    }
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
                : musicData.localSongs == null
                    ? [
                        IconButton(
                            icon: Icon(Icons.file_download),
                            onPressed: () => _loadTest(musicData))
                      ]
                    : null,
            centerTitle: true),
        body: _buildBody(musicData));
  }

  _loadTest(MusicData musicData) async {
    await testSongs.forEach((Song song) async {
      await downloadSong(song);
    });
    setState(() {
      _musicList = musicData.localSongs;
    });
  }

  _buildBody(MusicData musicData) {
    return _musicList.length > 0
        ? RefreshIndicator(
            key: _refreshKey,
            onRefresh: () => _loadPlaylist(musicData, null),
            child: ListView.builder(
              itemCount: _musicList.length,
              itemBuilder: (context, index) =>
                  _buildSongListTile(index, musicData),
            ))
        : Center(
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.2),
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        'No saved songs',
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                        textAlign: TextAlign.center,
                      ))
                ])));
  }

  _loadPlaylist(MusicData musicData, Song song) async {
    if (widget._pageType == PageType.SAVED) {
      await musicData.loadSavedMusic();
      await setState(() {
        _musicList = musicData.localSongs;
      });
    } else {}
    if (song != null) {
      musicData.setPlaylistSongs(_musicList, song);
    }
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
                            _musicList.remove(song);
                          });
                        } catch (e) {
                          print(e);
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
    Song song = _musicList[index];
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
            _loadPlaylist(sharedData, song);
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
