import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/utils/hex_color.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:vk_parse/functions/utils/pickDialog.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:vk_parse/utils/Database.dart';
import 'package:vk_parse/provider/MusicData.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'PlayerPage.dart';

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
  List<Playlist> _playlistList = [];
  bool init = true;

  _addTrackToPlaylistDialog() {}

  _loadPlaylistList() async {
    List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();
    if (mounted) {
      setState(() {
        _playlistList = playlistList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlaylistList();
  }

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    if (init) {
      init = false;
      _loadPlaylist(musicData, null);
    }

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
                middle: Text(widget._pageType == PageType.PLAYLIST
                    ? widget.playlist.title
                    : 'Media'),
                previousPageTitle: 'Back',
                trailing: widget._pageType == PageType.PLAYLIST
                    ? GestureDetector(
                        child: Icon(Icons.add, color: Colors.white, size: 25),
                        onTap: () => _addTrackToPlaylistDialog())
                    : null),
            child: _buildBody(musicData)));
  }

  _buildBody(MusicData musicData) {
    return RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => _loadPlaylist(musicData, null, update: true),
        child: _musicList.length > 0
            ? ListView.builder(
                itemCount: _musicList.length,
                itemBuilder: (context, index) =>
                    _buildSongListTile(index, musicData),
              )
            : ListView(children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      widget._pageType == PageType.SAVED
                          ? 'No saved songs'
                          : 'Empty playlist',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                      textAlign: TextAlign.center,
                    ))
              ]));
  }

  _loadPlaylist(MusicData musicData, Song song, {bool update = false}) async {
    if (widget._pageType == PageType.SAVED) {
      if (update) musicData.loadSavedMusic();
      setState(() {
        _musicList = musicData.localSongs;
      });
    } else {}
    if (song != null) {
      musicData.setPlaylistSongs(_musicList, song);
    }
  }

  _deleteSongFromPlaylist(Song song) {}

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
                      placeholder: 'Artist',
                      decoration: BoxDecoration(
                          color: HexColor('#303030'),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    Divider(height: 10, color: Colors.transparent),
                    CupertinoTextField(
                      controller: titleFilter,
                      placeholder: 'Title',
                      decoration: BoxDecoration(
                          color: HexColor('#303030'),
                          borderRadius: BorderRadius.circular(9)),
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
        fileName: song.toFileName() + '.mp3',
        mimeType: 'song/mp3',
        bytesOfFile: bytes.readAsBytesSync());
  }

  List<Widget> _actionsPane(Song song) {
    List<Widget> actions = [];
    if (widget._pageType == PageType.SAVED) {
      actions.add(IconSlideAction(
        caption: 'Add to playlist',
        color: Colors.pinkAccent,
        icon: SFSymbols.rectangle_stack_fill_badge_plus,
        onTap: () => showPickerDialog(context, _playlistList, song.song_id),
      ));
    }
    actions.add(IconSlideAction(
      caption: 'Rename',
      color: Colors.blue,
      icon: SFSymbols.pencil,
      onTap: () => _renameSongDialog(song),
    ));
    return actions;
  }

  _buildSongListTile(int index, MusicData musicData) {
    Song song = _musicList[index];
    if (song == null) {
      return null;
    }
    return Stack(children: [
      Column(children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: new Container(
              height: 72,
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () async {
                  _loadPlaylist(musicData, song);

                    if (musicData.currentSong != null &&
                        musicData.currentSong.song_id == song.song_id) {
                      await musicData.playerResume();
                    } else {
                      await musicData.playerPlay(song);
                    }
                      Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ChangeNotifierProvider<MusicData>.value(
                                value: musicData, child: PlayerPage()),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        }));
                },
                trailing: Text(formatDuration(song.duration),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          actions: _actionsPane(song),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Share',
              color: Colors.indigo,
              icon: CupertinoIcons.share_up,
              onTap: () => _shareSong(song),
            ),
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: SFSymbols.trash,
              onTap: () => widget._pageType == PageType.SAVED
                  ? _deleteSong(song)
                  : _deleteSongFromPlaylist(song),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Divider(height: 1, color: Colors.grey))
      ]),
      musicData.isPlaying(song.song_id)
          ? Container(
              height: 72,
              width: 3,
              decoration: BoxDecoration(color: Colors.white),
            )
          : Container(),
    ]);
  }
}
