import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';
import 'package:vk_parse/ui/MusicList.dart';

class PlaylistPage extends StatefulWidget {
  List<Playlist> _playlistList = [Playlist(title: 'Test playlist')];

  @override
  State<StatefulWidget> createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _createPlaylist(String playlistName) {
    setState(() {
      widget._playlistList.add(Playlist(title: playlistName));
    });
  }

  _createPlaylistShowDialog() async {
    final TextEditingController playlistName = new TextEditingController();

    showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Create playlist'),
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
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Create"),
                onPressed: () {
                  if (playlistName.text.isNotEmpty) {
                    _createPlaylist(playlistName.text);
                  }
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  _checkDirectory() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/playylists/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<ProjectData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar:
            new AppBar(title: Text('Playlists'), centerTitle: true, actions: [
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _createPlaylistShowDialog)
        ]),
        body: ListView.builder(
          itemCount: widget._playlistList.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) => _buildPlaylistList(sharedData, index),
        ));
  }

  _buildPlaylistList(ProjectData data, int index) {
    Playlist playlist = widget._playlistList[index];

    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
                title: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(playlist.title,
                        style: TextStyle(
                            color: Color.fromRGBO(200, 200, 200, 1)))),
                onTap: () {
                  Navigator.of(_scaffoldKey.currentContext).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<ProjectData>.value(
                                    value: data, child: MusicList([], title: playlist.title,))));
                },
                leading: playlist.image != null
                    ? CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            Image.memory(playlist.getImage()).image)
                    : CircleAvatar(
                        radius: 25,
                        child: Text(
                          playlist.title[0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        backgroundColor: Colors.redAccent))),
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Play',
            color: Colors.blue,
            icon: Icons.play_arrow,
            onTap: null,
          ),
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: null,
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
