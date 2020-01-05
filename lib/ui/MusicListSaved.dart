import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

class MusicListSaved extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListSavedState();
  }
}

class MusicListSavedState extends State<MusicListSaved> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> menuKey = new GlobalKey<ScaffoldState>();

  List<Song> _data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Saved Music', menuKey),
      backgroundColor: lightGrey,
      body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async => await _loadSongs(),
          child: ListView(
            children: _buildList(),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
    saveCurrentRoute('/MusicListSaved');
  }

  _loadSongs() async {
    final listSong = await requestMusicListGet();
    if (listSong != null) {
      setState(() {
        _data = listSong;
      });
    } else {
      infoDialog(context, "Unable to get Music List", "Something went wrong.");
    }
  }

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }
    return _data
        .map((Song song) => ListTile(
            title: Text(song.name),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            trailing: Container(
              child: new Text(song.duration.toString()),
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                },
                icon: Icon(
                  Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
