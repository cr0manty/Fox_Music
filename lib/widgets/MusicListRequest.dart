import 'package:flutter/material.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/playSong.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';

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
  List<Song> _localData = [];

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async => await _loadSongs(),
        child: ListView(
          children: _buildList(),
        ));
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  _loadSongs() async {
    final listSong = await requestMusicListGet();
    if (listSong != null) {
      setState(() {
        if (_data.isEmpty) {
          _data = listSong;
        }
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
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new Text(formatTime(song.duration)),
                ),
                Container(
                  child: new IconButton(
                    onPressed: _localData.contains(song)
                        ? null
                        : () {
                            downloadSong(song, context: context);
                          },
                    icon: Icon(Icons.file_download,
                        size: 35, color: Color.fromRGBO(100, 100, 100, 1)),
                  ),
                )
              ],
            ),
            leading: IconButton(
                onPressed: () async {
                  print('play started');
                  playSong(song.download);
                },
                icon: Icon(Icons.play_arrow,
                    size: 35, color: Color.fromRGBO(100, 100, 100, 1)))))
        .toList();
  }
}
