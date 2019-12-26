import 'package:vk_parse/SongData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';

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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String formatTime(int time) {
    Duration duration = Duration(seconds: time.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  _loadSongs() async {
    final response = await http.get('http://10.0.2.2:8000/api/songs/list/');
    if (response.statusCode == 200) {
      var songsData =
          (json.decode(response.body) as Map)['songs'] as List<dynamic>;

      var songList = List<Song>();
      songsData.forEach((dynamic value) {
        var song = Song(
            name: value['name'],
            artist: value['artist'],
            duration: formatTime(value['duration']),
            songId: value['song_id'],
            postedAt: DateTime.parse(value['posted_at']),
            download: value['download']);
        songList.add(song);
      });
      setState(() {
        data = songList.reversed.toList();
      });
    }
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
