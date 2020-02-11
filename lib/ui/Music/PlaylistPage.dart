import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/MusicData.dart';
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
      _playlistList.add(playlist);
    });
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

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<MusicData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar:
            new AppBar(title: Text('Playlists'), centerTitle: true, actions: [
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _createPlaylistShowDialog)
        ]),
        body: ListView.builder(
          itemCount: _playlistList.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _buildPlaylistList(sharedData, index),
        ));
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
                                    [],
                                    playlist: playlist,
                                  ))));
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
          new IconSlideAction(
            caption: 'Set image',
            color: Colors.pinkAccent,
            icon: Icons.image,
            onTap: null,
          ),
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              DBProvider.db.deletePlaylist(playlist.id);
            },
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
