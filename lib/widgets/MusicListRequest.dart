import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';

class MusicListRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MusicListRequestState();
}

class MusicListRequestState extends State<MusicListRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
  new GlobalKey<RefreshIndicatorState>();
  List<Song> _data = [];
  Song playedSong;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<ProjectData>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: Text('Music'), centerTitle: true),
        body: new RefreshIndicator(
            key: _refreshKey,
            onRefresh: () async => await _loadSongs(),
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) =>
                  _buildSongListTile(index, sharedData),
            )));
  }

  _setUpdatingStatus() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  _loadSongs() async {
    _setUpdatingStatus();
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
    _setUpdatingStatus();
  }

  _buildSongListTile(int index, ProjectData sharedData) {
    Song song = _data[index];
    if (song == null) {
      return null;
    }
    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: new Container(
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 30, right: 20),
              title: Text(song.title,
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              subtitle: Text(song.artist,
                  style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
              onTap: () {
                downloadSong(song, context: context);
              },
              trailing: Text(formatDuration(song.duration),
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
            )),
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: null,
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
