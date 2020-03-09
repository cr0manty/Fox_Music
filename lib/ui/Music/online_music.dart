import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/ui/Account/sign_in.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/utils/tile_list.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/utils/snackbar.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/api/music_list.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Account/auth_vk.dart';
import 'package:fox_music/utils/apple_search.dart';

class OnlineMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  StreamSubscription _playerNotifyState;
  bool init = true;
  Song playedSong;
  List<Song> dataSongSorted = [];
  bool isEmptySearch = true;

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    if (isEmptySearch) dataSongSorted = downloadData.dataSong;

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
                    'In order to listen, you have to allow access to your account details',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )));
  }

  void _filterSongs(MusicDownloadData downloadData, String value) {
    if (value.isNotEmpty) {
      String newValue = value.toLowerCase();
      setState(() {
        isEmptySearch = false;
        dataSongSorted = downloadData.dataSong
            .where((song) =>
                song.artist.toLowerCase().contains(newValue) ||
                song.title.toLowerCase().contains(newValue))
            .toList();
      });
    } else {
      isEmptySearch = false;
    }
  }

  _buildSongListTile(
      MusicDownloadData downloadData, MusicData musicData, int index) {
    if (index == 0)
      return AppleSearch(
          onChange: (value) => _filterSongs(downloadData, value));

    Song song = dataSongSorted[index - 1];
    if (init) {
      _playerNotifyState = downloadData.onResultChanged.listen((result) {
        if (result == DownloadState.COMPLETED) musicData.loadSavedMusic();
        downloadData.showInfo(_scaffoldKey.currentContext, result);
      });
      init = false;
    }

    return Stack(children: [
      Column(children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
              height: 60,
              child: TileList(
                padding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () {},
                trailing: Text(formatDuration(song.duration),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          actions: <Widget>[
            SlideAction(
              color: Colors.deepPurple,
              child: Icon(SFSymbols.arrow_down, color: Colors.white),
              onTap: () async {
                if (downloadData.inQuery(song)) {
                  if (downloadData.currentSong == song) {
                    showSnackBar(context, 'Unable to remove from queue',
                        seconds: 3);
                  } else {
                    downloadData.deleteFromQuery(song);
                  }
                } else {
                  downloadData.query = song;
                }
              },
            )
          ],
          secondaryActions: <Widget>[
            SlideAction(
              color: main_color,
              child: Icon(SFSymbols.trash, color: Colors.white),
              onTap: () async {
                hideMusic(song.song_id);
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
      ]),
      downloadData.currentSong == song
          ? Container(
              height: 60,
              width: MediaQuery.of(context).size.width * downloadData.progress,
              decoration: BoxDecoration(color: main_color.withOpacity(0.2)),
            )
          : downloadData.inQuery(song)
              ? Container(
                  height: 60,
                  width: 4,
                  alignment: Alignment.centerRight,
                  decoration:
                      BoxDecoration(color: Colors.orange.withOpacity(0.5)),
                )
              : Container(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _playerNotifyState?.cancel();
  }
}
