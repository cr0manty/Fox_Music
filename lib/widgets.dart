import 'package:vk_parse/SongData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<Song> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      var songs_data =
          (json.decode(response.body) as Map)['songs'] as List<dynamic>;

      var song_list = List<Song>();
      songs_data.forEach((dynamic value) {
        var song = Song(
            name: value['name'],
            artist: value['artist'],
            duration: formatTime(value['duration']),
            song_id: value['song_id'],
            posted_at: DateTime.parse(value['posted_at']),
            download: value['download']);
        song_list.add(song);
      });
      setState(() {
        data = song_list;
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
