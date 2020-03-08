import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/utils/database.dart';
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
    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(
            actionsForegroundColor: Colors.redAccent,
            middle: Text('Playlists'),
            previousPageTitle: 'Back',
            trailing: GestureDetector(
                child: Icon(
                  SFSymbols.plus,
                  color: Colors.white,
                  size: 25,
                ),
                onTap: () => _playlistDialog())),
        child: Material(
            color: Colors.transparent,
            child: _playlistList.length > 0
                ? ListView.builder(
                    itemCount: _playlistList.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        _buildPlaylistList(sharedData, index),
                  )
                : SafeArea(
                    child: Center(
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
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: Image.file(file).image);
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
                onTap: () async {
                  Navigator.of(_scaffoldKey.currentContext).push(
                      CupertinoPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<MusicData>.value(
                                  value: data,
                                  child: MusicListPage(playlist: playlist))));
                },
                leading: _showImage(playlist))),
        actions: <Widget>[
          SlideAction(
            color: Colors.blue,
            child: Icon(SFSymbols.play, color: Colors.white),
            onTap: null,
          ),
          SlideAction(
            color: Colors.pinkAccent,
            child: Icon(SFSymbols.photo, color: Colors.white),
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
          SlideAction(
            color: Colors.indigo,
            child: Icon(SFSymbols.pencil, color: Colors.white),
            onTap: () => _playlistDialog(playlist: playlist),
          ),
          SlideAction(
            color: Colors.red,
            child: Icon(SFSymbols.trash, color: Colors.white),
            onTap: () {
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
