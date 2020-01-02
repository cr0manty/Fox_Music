import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/infoDialog.dart';

class MusicListRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListRequestState();
  }
}

class MusicListRequestState extends State<MusicListRequest> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  List<Song> _data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Web Music List'),
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
  }

  _loadSongs() async {
    final listSong = await requestMusicListGet(context);
    if (listSong != null) {
      setState(() {
        _data = listSong;
      });
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
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new Text(song.duration.toString()),
                ),
                Container(
                  child: new IconButton(
                    onPressed: () {
                      print('download');
                    },
                    icon: Icon(Icons.file_download, size: 35),
                  ),
                )
              ],
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                },
                icon: Icon(
                  Icons.play_circle_filled,
                  size: 35,
                ))))
        .toList();
  }
}
