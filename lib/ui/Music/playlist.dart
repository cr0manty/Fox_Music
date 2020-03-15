import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/utils/database.dart';
import 'package:fox_music/utils/tile_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/ui/Music/music_list.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class PlaylistPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Playlist> _playlistList = [];

  _createPlaylist(MusicData musicData, String playlistName) async {
    musicData.playlistListUpdate = true;
    Playlist playlist = new Playlist(title: playlistName);
    await DBProvider.db.newPlaylist(playlist);
    setState(() {
      _playlistList.insert(0, playlist);
    });
  }

  _renamePlaylist(Playlist playlist, String playlistName) async {
    setState(() {
      playlist.title = playlistName;
    });
    DBProvider.db.updatePlaylist(playlist);
  }

  _loadPlaylist() async {
    List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();

    setState(() {
      _playlistList = playlistList;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  _playlistDialog(MusicData musicData, {Playlist playlist}) async {
    final TextEditingController playlistName = new TextEditingController();

    if (playlist != null) {
      playlistName.text = playlist.title;
    }

    showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(playlist == null ? 'Create playlist' : 'Rename playlist'),
          content: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(children: <Widget>[
                    CupertinoTextField(
                      controller: playlistName,
                      placeholder: 'Playlist name',
                      decoration: BoxDecoration(
                          color: HexColor('#303030'),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ]))),
          actions: <Widget>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(playlist == null ? 'Create' : 'Rename'),
                onPressed: () {
                  musicData.playlistUpdate = true;
                  if (playlistName.text.isNotEmpty) {
                    if (playlist != null)
                      _renamePlaylist(playlist, playlistName.text);
                    else
                      _createPlaylist(musicData, playlistName.text);
                  }
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    if (musicData.playlistPageUpdate) {
      _loadPlaylist();
      musicData.playlistPageUpdate = false;
    }

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(
            actionsForegroundColor: main_color,
            middle: Text('Playlists'),
            previousPageTitle: 'Back',
            trailing: GestureDetector(
                child: Icon(
                  SFSymbols.plus,
                  color: Colors.white,
                  size: 25,
                ),
                onTap: () => _playlistDialog(musicData))),
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
                child: _playlistList.length > 0
                    ? ReorderableListView(
                    scrollDirection: Axis.vertical,
                    onReorder: (oldIndex, newIndex) {
                      setState(
                            () {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final Playlist item =
                          _playlistList.removeAt(oldIndex);
                          _playlistList.insert(newIndex, item);
                        },
                      );
                    },
                    children: List.generate(
                      _playlistList.length,
                          (index) => _buildPlaylistList(musicData, index),
                    ))
                    : Container(
                    padding: EdgeInsets.only(top: 30),
                    alignment: Alignment.topCenter,
                    child: Text(
                      'You have no playlists yet',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                      textAlign: TextAlign.center,
                    )))));
  }

  _setImage(Playlist playlist, File image) async {
    if (image != null) {
      await setState(() {
        playlist.image = image.path;
      });
      await DBProvider.db.updatePlaylist(playlist);
    }
  }

  _showImage(Playlist playlist) {
    if (playlist.image != null) {
      File file = File(playlist.image);
      if (file.existsSync()) {
        return CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey,
            backgroundImage: Image
                .file(file)
                .image);
      } else {
        playlist.image = null;
        DBProvider.db.updatePlaylist(playlist);
      }
    }
    return CircleAvatar(
        radius: 22,
        child: Text(
          playlist.title[0].toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: main_color);
  }

  void _shufflePlaylist() {

  }

  _buildPlaylistList(MusicData musicData, int index) {
    Playlist playlist = _playlistList[index];

    return Column(
        key: Key('$index'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
                child: TileList(
                  padding: EdgeInsets.only(
                      left: 16, right: 8, top: 4, bottom: 4),
                  title: Text(playlist.title,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(200, 200, 200, 1))),
                  onTap: () async {
                    Navigator.of(_scaffoldKey.currentContext).push(
                        CupertinoPageRoute(
                            builder: (context) =>
                            ChangeNotifierProvider<MusicData>.value(
                                value: musicData,
                                child: MusicListPage(playlist: playlist))));
                  },
                  leading: Container(padding: EdgeInsets.only(right: 20),
                      child: _showImage(playlist)),
                  trailing: GestureDetector(
                      onTap: () => _shufflePlaylist(),
                      child: Container(
                          color: Colors.transparent,
                          padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Icon(
                            SFSymbols.shuffle,
                            color: Colors.grey,
                            size: 20,
                          ))),
                )),
            actions: <Widget>[
              SlideAction(
                color: HexColor('#3a4e93'),
                child: Icon(SFSymbols.play, color: Colors.white),
                onTap: null,
              ),
              SlideAction(
                color: HexColor('#a04db5'),
                child: Icon(SFSymbols.pencil, color: Colors.white),
                onTap: () => _playlistDialog(musicData, playlist: playlist),
              ),
            ],
            secondaryActions: <Widget>[
              SlideAction(
                color: HexColor('#5994ce'),
                child: Icon(SFSymbols.photo, color: Colors.white),
                onTap: () {
                  FocusScope.of(_scaffoldKey.currentContext)
                      .requestFocus(FocusNode());
                  showCupertinoModalPopup(
                      context: _scaffoldKey.currentContext,
                      builder: (context) {
                        return CupertinoActionSheet(
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  File _image = await ImagePicker.pickImage(
                                      source: ImageSource.camera);
                                  _setImage(playlist, _image);
                                },
                                child: Text('Camera', style: TextStyle(
                                    color: Colors.blue))),
                            CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  File _image = await ImagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  _setImage(playlist, _image);
                                },
                                child: Text('Gallery', style: TextStyle(
                                    color: Colors.blue))),
                            CupertinoActionSheetAction(
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await setState(() {
                                    playlist.image = null;
                                  });
                                  await DBProvider.db.updatePlaylist(playlist);
                                },
                                child: Text('Delete'))
                          ],
                        );
                      });
                },
              ),
              SlideAction(
                color: HexColor('#e22368'),
                child: Icon(SFSymbols.trash, color: Colors.white),
                onTap: () {
                  musicData.playlistListUpdate = true;
                  setState(() {
                    _playlistList.remove(playlist);
                  });
                  DBProvider.db.deletePlaylist(playlist.id);
                },
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Divider(height: 1, color: Colors.grey))
        ]);
  }
}
