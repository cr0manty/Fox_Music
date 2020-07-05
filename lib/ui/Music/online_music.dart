import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/provider/api.dart';
import 'package:fox_music/ui/Account/auth_vk.dart';
import 'package:fox_music/widgets/border_button.dart';
import 'package:fox_music/provider/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/widgets/offline.dart';
import 'package:fox_music/widgets/tile_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/widgets/apple_search.dart';

class OnlineMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _playerNotifyState;
  bool init = true;
  bool visible = true;
  Song playedSong;
  List<Song> dataSongSorted = [];

  void _addSongLink(MusicDownloadData downloadData) {
    final TextEditingController artist = TextEditingController();
    final TextEditingController title = TextEditingController();
    final TextEditingController duration = TextEditingController();
    final TextEditingController link = TextEditingController();

    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text('Add song'),
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
                              color: HexColor.mainText(),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: title,
                          placeholder: 'Song title',
                          decoration: BoxDecoration(
                              color: HexColor.mainText(),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: duration,
                          keyboardType: TextInputType.number,
                          placeholder: 'Duration in seconds',
                          decoration: BoxDecoration(
                              color: HexColor.mainText(),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        Divider(height: 10, color: Colors.transparent),
                        CupertinoTextField(
                          controller: link,
                          placeholder: 'mp3 link',
                          decoration: BoxDecoration(
                              color: HexColor.mainText(),
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
                      Map result = await Api.addNewSong(body);

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
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    if (init) {
      init = false;
      visible = ConnectionsCheck.instance.isOnline;
      _filterSongs(downloadData);
    }

    if (ConnectionsCheck.instance.isOnline) {
      if (AccountData.instance.user != null && downloadData.dataSong.isEmpty) {
        downloadData.loadMusic();
      }
    }

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
              actionsForegroundColor: HexColor.main(),
              middle: Text('Music'),
              trailing: AccountData.instance.user == null ||
                      !ConnectionsCheck.instance.isOnline
                  ? null
                  : GestureDetector(
                      onTap: () => downloadData.updateVKMusic(),
                      child: Icon(
                        SFSymbols.arrow_clockwise,
                        size: 25,
                      ),
                    ),
            ),
            child: Stack(children: <Widget>[
              _buildBody(downloadData),
              AnimatedOpacity(
                  onEnd: () => setState(() => visible = !visible),
                  opacity: ConnectionsCheck.instance.isOnline ? 0 : 1,
                  duration: Duration(milliseconds: 800),
                  child: !visible ? OfflinePage() : Container())
            ])));
  }

  Widget _provideData() {
    List<Widget> children = AccountData.instance.user != null
        ? [
            Text(
              'To listen you have to sign in to your VK account',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Divider(height: 20),
            BorderButton(
                text: 'Sign in',
                color: Colors.grey,
                onPressed: () => Navigator.of(_scaffoldKey.currentContext).push(
                    CupertinoPageRoute(
                        builder: (context) => VKAuthPage())))
          ]
        : [
            Text(
              'To listen you have to sign up or sign in',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            )
          ];

    return Center(
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.2),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.2),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children))));
  }

  _buildBody(MusicDownloadData downloadData) {
    return AccountData.instance.user != null &&
            (AccountData.instance.user.can_use_vk || AccountData.instance.user.is_staff)
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
                    dataSongSorted.length + 2,
                    (index) => _buildSongListTile(downloadData, index))))
          ]))
        : _provideData();
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
                          progressColor: HexColor.main(),
                        ))
                    : Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: Icon(SFSymbols.cloud_download,
                            color: downloadData.inQuery(song)
                                ? HexColor.main()
                                : Colors.grey),
                      )));
  }

  _buildSongListTile(MusicDownloadData downloadData, int index) {
    if (index == 0) {
      return AppleSearch(
          controller: controller,
          onChange: (value) => _filterSongs(downloadData, value: value));
    }

    if (index >= dataSongSorted.length + 1) {
      return Container(height: 75);
    }

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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () async {
                  bool isLocal = downloadData.musicData.isLocal;
                  await downloadData.musicData
                      .setPlaylistSongs(dataSongSorted, song, local: false);
                  if (downloadData.musicData.currentSong != null &&
                      downloadData.musicData.currentSong.song_id ==
                          song.song_id &&
                      !isLocal) {
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
                  Api.hideMusic(song.song_id);
                  setState(() {
                    downloadData.dataSong.remove(song);
                    dataSongSorted = downloadData.dataSong;
                  });
                })
          ]),
      Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Divider(height: 1, color: Colors.grey))
    ]);
  }

  @override
  void dispose() {
    _playerNotifyState?.cancel();
    super.dispose();
  }
}
