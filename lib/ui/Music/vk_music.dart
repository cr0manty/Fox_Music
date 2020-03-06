import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/functions/utils/snackbar.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:vk_parse/provider/account_data.dart';
import 'package:vk_parse/provider/music_data.dart';
import 'package:vk_parse/models/song.dart';
import 'package:vk_parse/api/music_list.dart';
import 'package:vk_parse/functions/utils/info_dialog.dart';
import 'package:vk_parse/functions/format/time.dart';
import 'package:vk_parse/provider/download_data.dart';
import 'package:vk_parse/ui/Account/auth_vk.dart';
import 'package:vk_parse/utils/apple_search.dart';

class VKMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new VKMusicListPageState();
}

class VKMusicListPageState extends State<VKMusicListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  StreamSubscription _playerNotifyState;
  bool init = true;
  Song playedSong;
  List<Song> dataSongSorted = [];

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    if (init) {
      dataSongSorted = downloadData.dataSong;
    }

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
                actionsForegroundColor: Colors.redAccent,
                middle: Text('Music'),
                trailing:
                    accountData.user != null && accountData.user.can_use_vk
                        ? IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () async {
                              try {
                                final listNewSong = await musicListPost();
                                if (listNewSong != null) {
                                  infoDialog(
                                      _scaffoldKey.currentContext,
                                      "New songs",
                                      "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
                                } else {
                                  infoDialog(
                                      _scaffoldKey.currentContext,
                                      "Something went wrong",
                                      "Unable to get Music List.");
                                }
                              } catch (e) {
                                print(e);
                              } finally {
                                downloadData.loadMusic();
                              }
                            },
                          )
                        : null),
            child: _buildBody(accountData, downloadData, musicData)));
  }

  _buildBody(AccountData accountData, MusicDownloadData downloadData,
      MusicData musicData) {
    return accountData.user != null &&
            (accountData.user.can_use_vk || accountData.user.is_staff)
        ? RefreshIndicator(
            key: _refreshKey,
            onRefresh: () => downloadData.loadMusic(),
            child: ListView.builder(
              itemCount: dataSongSorted.length + 1,
              itemBuilder: (context, index) =>
                  _buildSongListTile(downloadData, musicData, index),
            ))
        : Center(
            child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.2),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Stack(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: Text(
                    'In order to listen, you have to allow access to your account details',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
              Center(
                  child: CupertinoButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.of(_scaffoldKey.currentContext).push(
                      CupertinoPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<AccountData>.value(
                                  value: accountData,
                                  child: VKAuthPage(accountData))));
                },
              )),
            ]),
          ));
  }

  void _filterSongs(MusicDownloadData downloadData, String value) {
    String newValue = value.toLowerCase();
    setState(() {
      dataSongSorted = downloadData.dataSong
          .where((song) =>
              song.artist.toLowerCase().contains(newValue) ||
              song.title.toLowerCase().contains(newValue))
          .toList();
    });
  }

  _buildSongListTile(
      MusicDownloadData downloadData, MusicData musicData, int index) {
    if (index == 0)
      return AppleSearch(
          onChange: (value) => _filterSongs(downloadData, value));

    Song song = downloadData.dataSong[index - 1];
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
              height: 72,
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
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
                trailing: Text(formatDuration(song.duration),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          secondaryActions: <Widget>[
            SlideAction(
              color: Colors.red,
              child: Icon(SFSymbols.trash, color: Colors.white),
              onTap: () async {
                bool isDeleted = await hideMusic(song.song_id);
                if (isDeleted) {
                  setState(() {
                    downloadData.dataSong.removeAt(index);
                  });
                }
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
              height: 72,
              width: MediaQuery.of(context).size.width * downloadData.progress,
              decoration:
                  BoxDecoration(color: Colors.redAccent.withOpacity(0.2)),
            )
          : downloadData.inQuery(song)
              ? Container(
                  height: 72,
                  width: 3,
                  decoration: BoxDecoration(color: Colors.grey),
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
