import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/models/downloaded_song.dart';
import 'package:fox_music/utils/circle_progress.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/utils/tile_list.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/utils/snackbar.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/api/music_list.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/utils/apple_search.dart';

class OnlineMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _playerNotifyState;
  bool init = true;
  Song playedSong;
  List<DownloadedSong> dataSongSorted = [];

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    if (init) _filterSongs(downloadData);

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
                actionsForegroundColor: main_color, middle: Text('Music')),
            child: _buildBody(accountData, downloadData, musicData)));
  }

  _buildBody(AccountData accountData, MusicDownloadData downloadData,
      MusicData musicData) {
    return accountData.user != null &&
            (accountData.user.can_use_vk || accountData.user.is_staff)
        ? SafeArea(
            child: CustomScrollView(slivers: <Widget>[
            CupertinoSliverRefreshControl(onRefresh: () async {
              await downloadData.loadMusic();

              setState(() {
                dataSongSorted = downloadData.dataSong;
                _filterSongs(downloadData, value: controller.text);
              });
            }),
            SliverList(
                delegate: SliverChildListDelegate(List.generate(
                    dataSongSorted.length + 1,
                    (index) =>
                        _buildSongListTile(downloadData, musicData, index))))
          ]))
        : Center(
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.2),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: Text(
                    'To listen you have to sign up or log in',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )));
  }

  void _filterSongs(MusicDownloadData downloadData, {String value}) {
    if (value == null) {
      dataSongSorted = downloadData.dataSong;
    } else if (value.isNotEmpty) {
      String newValue = value.toLowerCase();
      setState(() {
        dataSongSorted = downloadData.dataSong
            .where((song) =>
                song.song.artist.toLowerCase().contains(newValue) ||
                song.song.title.toLowerCase().contains(newValue))
            .toList();
      });
    } else if (value.isEmpty) {
      setState(() {
        dataSongSorted = downloadData.dataSong;
      });
    }
  }

  Widget _drawDownloadIcon(
      MusicDownloadData downloadData, DownloadedSong song) {
    return Container(
        color: Colors.transparent,
        transform: Matrix4.translationValues(-5, 0, 0),
        height: 60,
        width: 50,
        child: GestureDetector(
            onTap: song.downloaded
                ? null
                : () async {
                    if (downloadData.inQuery(song.song)) {
                      await downloadData.deleteFromQuery(song.song);
                    } else if (downloadData.currentSong == song.song) {
                      await downloadData.cancelDownload();
                    } else {
                      await downloadData.addToQuery(song.song);
                    }
                  },
            child: song.downloaded
                ? Container(
                    transform: Matrix4.translationValues(-5, 0, 0),
                    child: Icon(SFSymbols.checkmark_alt, color: Colors.grey),
                  )
                : downloadData.currentSong == song.song
                    ? Container(
                        transform: Matrix4.translationValues(9, 0, 0),
                        child: CustomPaint(
                            painter:
                                ArcPainter(progress: downloadData.progress),
                            child: Container(
                              transform:
                                  Matrix4.translationValues(-13.5, -0.2, 0),
                              child: Icon(
                                SFSymbols.square_fill,
                                color: Colors.grey,
                                size: 10,
                              ),
                            )))
                    : Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: Icon(SFSymbols.cloud_download,
                            color: downloadData.inQuery(song.song)
                                ? main_color
                                : Colors.grey),
                      )));
  }

  List<Song> _createSongList() {
    List<Song> songs = [];
    dataSongSorted.forEach((song) {
      songs.add(song.song);
    });
    return songs;
  }

  _buildSongListTile(
      MusicDownloadData downloadData, MusicData musicData, int index) {
    if (index == 0)
      return AppleSearch(
          controller: controller,
          onChange: (value) => _filterSongs(downloadData, value: value));

    DownloadedSong song = dataSongSorted[index - 1];
    if (init) {
      _playerNotifyState = downloadData.onResultChanged.listen((result) {
        if (result == DownloadState.COMPLETED) musicData.loadSavedMusic();
        downloadData.showInfo(_scaffoldKey.currentContext, result);
      });
      init = false;
    }

    return Column(children: <Widget>[
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            height: 60,
            child: TileList(
              leading: _drawDownloadIcon(downloadData, song),
              padding: EdgeInsets.only(left: 30, right: 20),
              title: Text(song.song.title,
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              subtitle: Text(song.song.artist,
                  style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
              onTap: () async {
                musicData.setPlaylistSongs(_createSongList(), song.song,
                    local: false);
                if (musicData.currentSong != null &&
                    musicData.currentSong.song_id == song.song.song_id) {
                  await musicData.playerResume();
                } else {
                  await musicData.playerPlay(song.song);
                }
              },
              trailing: Text(formatDuration(song.song.duration),
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
            )),
        secondaryActions: <Widget>[
          SlideAction(
            color: HexColor('#d62d2d'),
            child: Icon(SFSymbols.trash, color: Colors.white),
            onTap: () async {
              hideMusic(song.song.song_id);
              setState(() {
                downloadData.dataSong.remove(song);
                dataSongSorted = downloadData.dataSong;
              });
            },
          ),
        ],
      ),
      Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Divider(height: 1, color: Colors.grey))
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _playerNotifyState?.cancel();
  }
}
