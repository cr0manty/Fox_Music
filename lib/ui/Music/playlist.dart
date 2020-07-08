import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/instances/database.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/widgets/tile_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/ui/Music/music_list.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class PlaylistPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  List<Playlist> _playlistList = [];

  _createPlaylist(String playlistName) async {
    MusicData.instance.playlistListUpdate = true;
    Playlist playlist = Playlist(title: playlistName);
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

  _playlistDialog({Playlist playlist}) async {
    final TextEditingController playlistName = TextEditingController();

    if (playlist != null) {
      playlistName.text = playlist.title;
    }

    showCupertinoDialog(
      context: context,
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
                          color: HexColor.mainText(),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ]))),
          actions: <Widget>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(playlist == null ? 'Create' : 'Rename'),
                onPressed: () {
                  MusicData.instance.playlistUpdate = true;
                  if (playlistName.text.isNotEmpty) {
                    if (playlist != null)
                      _renamePlaylist(playlist, playlistName.text);
                    else
                      _createPlaylist(playlistName.text);
                  }
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MusicData.instance.playlistPageUpdate) {
      _loadPlaylist();
      MusicData.instance.playlistPageUpdate = false;
    }

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            actionsForegroundColor: HexColor.main(),
            middle: Text('Playlists'),
            previousPageTitle: 'Back',
            trailing: GestureDetector(
                child: Icon(
                  SFSymbols.plus,
                  size: 25,
                ),
                onDoubleTap: Crashlytics.instance.crash,
                onTap: () => _playlistDialog())),
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
                child: _playlistList.length > 0
                    ? ListView(
                        children: List.generate(
                        _playlistList.length + 1,
                        (index) => _buildPlaylistList(index),
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
            backgroundImage: Image.file(file).image);
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
        backgroundColor: HexColor.main());
  }

  void _mixPlaylistSong(Playlist playlist) async {
    MusicData.instance.playPlaylist(playlist, mix: true);
  }

  _buildPlaylistList(int index) {
    if (index >= _playlistList.length) {
      return Container(height: 75);
    }

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
              padding: EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
              title: Text(playlist.title,
                  style: TextStyle(
                      fontSize: 18, color: Color.fromRGBO(200, 200, 200, 1))),
              onTap: () async {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => MusicListPage(playlist: playlist)));
              },
              leading: Container(
                  padding: EdgeInsets.only(right: 20),
                  child: _showImage(playlist)),
              trailing: GestureDetector(
                  onTap: () => _mixPlaylistSong(playlist),
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
                onTap: () => MusicData.instance.playPlaylist(playlist),
              ),
              SlideAction(
                color: HexColor('#a04db5'),
                child: Icon(SFSymbols.pencil, color: Colors.white),
                onTap: () => _playlistDialog(playlist: playlist),
              ),
            ],
            secondaryActions: <Widget>[
              SlideAction(
                color: HexColor('#5994ce'),
                child: Icon(SFSymbols.photo, color: Colors.white),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return CupertinoActionSheet(
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  File _image = await ImagePicker.pickImage(
                                      source: ImageSource.camera);
                                  _setImage(playlist, _image);
                                },
                                child: Text('Camera',
                                    style: TextStyle(color: Colors.blue))),
                            CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  File _image = await ImagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  _setImage(playlist, _image);
                                },
                                child: Text('Gallery',
                                    style: TextStyle(color: Colors.blue))),
                            CupertinoActionSheetAction(
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.of(context).pop();
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
                color: HexColor('#d62d2d'),
                child: Icon(SFSymbols.trash, color: Colors.white),
                onTap: () {
                  MusicData.instance.playlistListUpdate = true;
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
