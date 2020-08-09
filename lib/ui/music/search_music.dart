import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/utils/api.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/instances/download_data.dart';
import 'package:fox_music/widgets/apple_search.dart';

class SearchMusicPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchMusicPageState();
}

class SearchMusicPageState extends State<SearchMusicPage> {
  TextEditingController controller = TextEditingController();

  int addAmount = 0;
  List<Song> _songList = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          actionsForegroundColor: HexColor.main(),
          previousPageTitle: 'Back',
          middle: Text('Music Search'),
        ),
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _songList.isEmpty ? 2 : _songList.length + 1,
                  itemBuilder: (context, index) =>
                      _buildSongListTile(index),
                ))));
  }

  _buildSongListTile(int index) {
    if (index == 0) {
      return AppleSearch(
        controller: controller,
        onChange: (value) async {
          List<Song> songList = await Api.musicSearchGet(value);
          setState(() {
            _songList = songList;
          });
        },
      );
    } else if (index == 1 && _songList.isEmpty) {
      return Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            'Your search returned no results.',
            style: TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ));
    }

    Song song = _songList[index - 1];
    if (song == null) {
      return null;
    }
    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 30, right: 20),
              title: Text(song.title,
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              subtitle: Text(song.artist,
                  style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
              onTap: () async {
                await MusicData.instance
                    .setPlaylistSongs(_songList, song, local: false);
                if (MusicData.instance.currentSong != null &&
                    MusicData.instance.currentSong.songId == song.songId) {
                  await MusicData.instance.playerResume();
                } else {
                  await MusicData.instance
                      .playerPlay(index: _songList.indexOf(song));
                }
              },
              trailing: Text(song.formatDuration(),
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
            )),
        actions: song.inMyList == 0
            ? <Widget>[
          SlideAction(
            color: HexColor('#3a4e93'),
            child: Icon(SFSymbols.plus, color: Colors.white),
            onTap: () async {
              bool isAdded = await Api.addMusic(song.songId);
              if (isAdded ?? false) {
                setState(() {
                  song.inMyList = 1;
                  MusicDownloadData.instance.dataSong.insert(addAmount++, song);
                });
              }
            },
          ),
        ]
            : [],
        secondaryActions: song.inMyList == 1
            ? <Widget>[
          SlideAction(
            color: HexColor('#d62d2d'),
            child: Icon(SFSymbols.trash, color: Colors.white),
            onTap: () async {
              bool isDeleted = await Api.hideMusic(song.songId);
              if (isDeleted) {
                setState(() {
                  song.inMyList = 0;
                  MusicDownloadData.instance.dataSong.remove(song);
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
