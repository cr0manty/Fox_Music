import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/provider/MusicData.dart';
import 'package:vk_parse/ui/Music/MusicListPage.dart';
import 'package:vk_parse/utils/Database.dart';

class PlaylistPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Playlist> _playlistList = [];

  _createPlaylist(String playlistName) async {
    Playlist playlist = new Playlist(title: playlistName);
    await DBProvider.db.newPlaylist(playlist);
    setState(() {
      _playlistList.insert(0, playlist);
    });
  }

  _renamePlaylist(Playlist playlist, String playlistName) async {
    playlist.title = playlistName;
    await DBProvider.db.updatePlaylist(playlist);
    setState(() {});
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
                  if (playlistName.text.isNotEmpty) {
                    if (playlist != null)
                      _renamePlaylist(playlist, playlistName.text);
                    else
                      _createPlaylist(playlistName.text);
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
    final sharedData = Provider.of<MusicData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar:
        new AppBar(title: Text('Playlists'), centerTitle: true, actions: [
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _playlistDialog)
        ]),
        body: ListView.builder(
          itemCount: _playlistList.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _buildPlaylistList(sharedData, index),
        ));
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
            radius: 25,
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
        radius: 25,
        child: Text(
          playlist.title[0].toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.redAccent);
  }

  _buildPlaylistList(MusicData data, int index) {
    Playlist playlist = _playlistList[index];

    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
                title: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20, left: 7),
                    child: Text(playlist.title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromRGBO(200, 200, 200, 1)))),
                onTap: () {
                  Navigator.of(_scaffoldKey.currentContext).push(
                      MaterialPageRoute(
                          builder: (context) =>
                          ChangeNotifierProvider<MusicData>.value(
                              value: data,
                              child: MusicListPage(
                                playlist: playlist,
                              ))));
                },
                leading: _showImage(playlist))),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Play',
            color: Colors.blue,
            icon: Icons.play_arrow,
            onTap: null,
          ),
          IconSlideAction(
            caption: 'Set image',
            color: Colors.pinkAccent,
            icon: Icons.image,
            onTap: () {
              FocusScope.of(_scaffoldKey.currentContext)
                  .requestFocus(FocusNode());
              showCupertinoModalPopup(
                  context: _scaffoldKey.currentContext,
                  builder: (context) {
                    return CupertinoActionSheet(
                      title: Text('Choose image from...'),
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.pop(context);
                              File _image = await ImagePicker.pickImage(
                                  source: ImageSource.camera);
                              _setImage(playlist, _image);
                            },
                            child: Text('Camera')),
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.pop(context);
                              File _image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              _setImage(playlist, _image);
                            },
                            child: Text('Gallery')),
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
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Rename',
            color: Colors.indigo,
            icon: Icons.edit,
            onTap: () => _playlistDialog(playlist: playlist),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              setState(() {
                _playlistList.remove(playlist);
              });
              DBProvider.db.deletePlaylist(playlist.id);
            },
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
