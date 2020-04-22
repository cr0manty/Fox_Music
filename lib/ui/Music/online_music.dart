import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/api/add_new_song.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/utils/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/utils/offline.dart';
import 'package:fox_music/utils/tile_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/provider/account_data.dart';
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
  bool isOnline = true;
  Song playedSong;
  List<Song> dataSongSorted = [];

  _addSongLink(MusicDownloadData downloadData) {
    final TextEditingController artist = new TextEditingController();
    final TextEditingController title = new TextEditingController();
    final TextEditingController duration = new TextEditingController();
    final TextEditingController link = new TextEditingController();

    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text('Add new song'),
              content: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Card(
                      color: Colors.transparent,
                      elevation: 0.0,
                      child: Column(children: <Widget>[
                        CupertinoTextField(
                          controller: artist,
                          placeholder: 'Artist name',
                          decoration: BoxDecoration(
                              color: HexColor('#303030'),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: title,
                          placeholder: 'Song title',
                          decoration: BoxDecoration(
                              color: HexColor('#303030'),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: duration,
                          keyboardType: TextInputType.number,
                          placeholder: 'Duration in seconds',
                          decoration: BoxDecoration(
                              color: HexColor('#303030'),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: link,
                          placeholder: 'mp3 link',
                          decoration: BoxDecoration(
                              color: HexColor('#303030'),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                      ]))),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () async {
                      Map body = {
                        "artist": artist.text,
                        "title": title.text,
                        "duration": int.parse(
                            duration.text.isNotEmpty ? duration.text : '0'),
                        "download": link.text
                      };
                      Navigator.pop(context);

                      Map result = await addNewSong(body);

                      if (result['success']) {
                        infoDialog(_scaffoldKey.currentContext, 'Success',
                            'Song successfully added');
                        Song song = Song.fromJson(result['body']);
                        setState(() {
                          downloadData.dataSong.add(song);
                        });
                      } else {
                        infoDialog(_scaffoldKey.currentContext, 'Error',
                            result['body']['non_field_errors'][0].toString());
                      }
                    }),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    ConnectionsCheck connection = Provider.of<ConnectionsCheck>(context);

    if (init) _filterSongs(downloadData);

    if (connection.isOnline) {
      if (accountData.user == null || accountData.needUpdate) {
        accountData.init(true);
      }
      if (accountData.user != null && downloadData.dataSong.isEmpty) {
        downloadData.loadMusic();
      }
    }

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
              actionsForegroundColor: main_color,
              middle: Text('Music'),
              trailing: accountData.user == null || !connection.isOnline
                  ? null
                  : GestureDetector(
                      onTap: () => _addSongLink(downloadData),
                      child: Icon(
                        SFSymbols.plus,
                        size: 25,
                      ),
                    ),
            ),
            child: Stack(children: <Widget>[
              _buildBody(accountData, downloadData),
              AnimatedOpacity(
                  opacity: connection.isOnline ? 0 : 1,
                  duration: Duration(milliseconds: 800),
                  child: OfflinePage())
            ])));
  }

  _buildBody(AccountData accountData, MusicDownloadData downloadData) {
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
                    (index) => _buildSongListTile(downloadData, index))))
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
                song.artist.toLowerCase().contains(newValue) ||
                song.title.toLowerCase().contains(newValue))
            .toList();
      });
    } else if (value.isEmpty) {
      setState(() {
        dataSongSorted = downloadData.dataSong;
      });
    }
  }

  Widget _drawDownloadIcon(MusicDownloadData downloadData, Song song) {
    return Container(
        color: Colors.transparent,
        transform: Matrix4.translationValues(-5, 0, 0),
        height: 60,
        width: 50,
        child: GestureDetector(
            onTap: song.downloaded
                ? null
                : () async {
                    if (downloadData.inQuery(song)) {
                      await downloadData.deleteFromQuery(song);
                    } else if (downloadData.currentSong == song) {
                      await downloadData.cancelDownload();
                    } else {
                      await downloadData.addToQuery(song);
                    }
                  },
            child: song.downloaded
                ? Container(
                    transform: Matrix4.translationValues(-5, 0, 0),
                    child: Icon(SFSymbols.checkmark_alt, color: Colors.grey),
                  )
                : downloadData.currentSong == song
                    ? Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: CircularPercentIndicator(
                          radius: 24.0,
                          lineWidth: 2.0,
                          backgroundColor: Colors.grey,
                          percent: downloadData.progress,
                          center: Container(
                              transform: Matrix4.translationValues(0, -0.5, 0),
                              child: Icon(
                                SFSymbols.square_fill,
                                size: 11,
                                color: Colors.grey,
                              )),
                          progressColor: main_color,
                        ))
                    : Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: Icon(SFSymbols.cloud_download,
                            color: downloadData.inQuery(song)
                                ? main_color
                                : Colors.grey),
                      )));
  }

  _buildSongListTile(MusicDownloadData downloadData, int index) {
    if (index == 0)
      return AppleSearch(
          controller: controller,
          onChange: (value) => _filterSongs(downloadData, value: value));

    Song song = dataSongSorted[index - 1];
    if (init) {
      _playerNotifyState = downloadData.onResultChanged.listen((result) {
        if (result == DownloadState.COMPLETED)
          downloadData.musicData.loadSavedMusic();
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
              title: Text(song.title,
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              subtitle: Text(song.artist,
                  style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
              onTap: () async {
                await downloadData.musicData
                    .setPlaylistSongs(dataSongSorted, song, local: false);
                if (downloadData.musicData.currentSong != null &&
                    downloadData.musicData.currentSong.song_id ==
                        song.song_id) {
                  await downloadData.musicData.playerResume();
                } else {
                  await downloadData.musicData
                      .playerPlay(index: dataSongSorted.indexOf(song));
                }
              },
              trailing: Text(formatDuration(song.duration),
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
            )),
        secondaryActions: <Widget>[
          SlideAction(
            color: HexColor('#d62d2d'),
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
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _playerNotifyState?.cancel();
  }
}
