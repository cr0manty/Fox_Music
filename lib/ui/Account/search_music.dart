import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/showShackbar.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
import 'package:vk_parse/utils/apple_search.dart';

class SearchMusicPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SearchMusicPageState();
}

class SearchMusicPageState extends State<SearchMusicPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Song> _songList = [];

  @override
  Widget build(BuildContext context) {
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Music Search'),
          previousPageTitle: 'Back',
        ),
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
                child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _songList.length + 1,
              itemBuilder: (context, index) =>
                  _buildSongListTile(downloadData, index),
            ))));
  }

  _buildSongListTile(MusicDownloadData downloadData, int index) {
    if (index == 0) {
      return AppleSearch(
        onChange: (value) async {
          List<Song> songList = await musicSearchGet(value);
          setState(() {
            _songList = songList;
          });
        },
      );
    }
    Song song = _songList[index - 1];
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
            downloadData.query = song;
          },
          trailing: Text(formatDuration(song.duration),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: !song.in_my_list
            ? <Widget>[
                new IconSlideAction(
                  caption: 'Add',
                  color: Colors.blue,
                  icon: Icons.add,
                  onTap: () async {
                    bool isAdded = await addMusic(song.song_id);
                    if (isAdded == null) {
                      showSnackBar(context, 'Song alredy in your list');
                    } else if (isAdded) {
                      setState(() {
                        song.in_my_list = true;
                      });
                    }
                  },
                ),
              ]
            : [],
        secondaryActions: song.in_my_list
            ? <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    bool isDeleted = await hideMusic(song.song_id);
                    if (isDeleted) {
                      setState(() {
                        song.in_my_list = false;
                      });
                    }
                  },
                ),
              ]
            : [],
      ),
      Padding(
          padding: EdgeInsets.only(left: 22.0),
          child: Divider(height: 1, color: Colors.grey))
    ]);
  }

}
