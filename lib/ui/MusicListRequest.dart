import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/playSong.dart';

class MusicListRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListRequestState();
  }
}

class MusicListRequestState extends State<MusicListRequest> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> menuKey = new GlobalKey<ScaffoldState>();
  List<Song> _data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Music', menuKey),
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
    saveCurrentRoute('/MusicListRequest');
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
                      // TODO: mark downloaded
                      downloadSong(context, song);
                    },
                    icon: Icon(Icons.file_download,
                        size: 35, color: Color.fromRGBO(100, 100, 100, 1)),
                  ),
                )
              ],
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                  playSong(song.download);
                },
                icon: Icon(Icons.play_arrow,
                    size: 35, color: Color.fromRGBO(100, 100, 100, 1)))))
        .toList();
  }
}
