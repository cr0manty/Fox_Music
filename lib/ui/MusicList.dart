import 'package:vk_parse/models/Song.dart';
import 'package:flutter/material.dart';

import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/api/requestMusicList.dart';

class MusicList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListState();
  }
}

class MusicListState extends State<MusicList> {
  List<Song> data = [];
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      drawer: new Drawer(),
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () => _menuKey.currentState.openDrawer()),
        title: Text('VK Music'),
      ),
      backgroundColor: lightGrey,
      body: Container(
          child: ListView(
        children: _buildList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadSongs(),
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  _loadSongs() async {
    final listSong = await requestMusicList(context);
    setState(() {
      data = listSong;
    });
  }

  List<Widget> _buildList() {
    return data
        .map((Song song) => ListTile(
            title: Text(song.name),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            trailing: Text(song.duration.toString())))
        .toList();
  }
}
