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
  List<Song> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: new Drawer(),
      appBar: customAppBat,
      backgroundColor: lightGrey,
      body: Container(
          child: ListView(
        children: _buildList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadNewSongs(),
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  _loadNewSongs() async {
    try {
      final listNewSong = await requestMusicListPost(context);
      int newSongsAmount = listNewSong.length;

      showTextDialog(
          context, "New songs", "$newSongsAmount new songs found.", "OK");
      setState(() {
        data += listNewSong;
      });
    }
    catch (e) {
      print(e);
    }
  }

  _loadSongs() async {
    final listSong = await requestMusicListGet(context);
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
