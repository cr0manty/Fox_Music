import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/models/Database.dart';
import 'package:vk_parse/functions/get/getUserId.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/playSong.dart';

class MusicListSaved extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListSavedState();
  }
}

class MusicListSavedState extends State<MusicListSaved> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();

  List<Song> _data = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Saved Music', _menuKey),
      backgroundColor: lightGrey,
      body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async => await _refreshSongList(),
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

  _refreshSongList() {
    requestMusicListGet();
    _loadSongs();
  }

  _loadSongs() async {
    final userId = await getUserId();
    final listSong = await DBProvider.db.getAllUserSongs(userId);
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
              child: new Text(formatTime(song.duration)),
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                  playSong(song.localUrl);
                },
                icon: Icon(
                  Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
