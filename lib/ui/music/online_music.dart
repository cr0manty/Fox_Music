import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/utils/api.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/instances/utils.dart';
import 'package:fox_music/ui/Account/auth_vk.dart';
import 'package:fox_music/utils/help_tools.dart';
import 'package:fox_music/widgets/border_button.dart';
import 'package:fox_music/instances/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/widgets/offline.dart';
import 'package:fox_music/widgets/tile_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/instances/account_data.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/instances/download_data.dart';
import 'package:fox_music/widgets/apple_search.dart';

class OnlineMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  TextEditingController controller = TextEditingController();
  StreamSubscription _playerNotifyState;
  bool init = true;
  bool visible = ConnectionsCheck.instance.isOnline;
  Song playedSong;
  List<Song> dataSongSorted = [];
  bool updating = false;

  void _addSongLink() {
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
                    onPressed: Navigator.of(context).pop),
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
                      Navigator.of(context).pop();
                      Map result = await Api.addNewSong(body);

                      if (result['success']) {
                        HelpTools.infoDialog(
                            context, 'Success', 'Song successfully added');
                        Song song = Song.fromJson(result['body']);
                        setState(() {
                          MusicDownloadData.instance.dataSong.add(song);
                        });
                      } else {
                        HelpTools.infoDialog(context, 'Error',
                            result['body']['non_field_errors'][0].toString());
                      }
                    }),
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    _filterSongs();
    MusicDownloadData.instance.loadMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              actionsForegroundColor: HexColor.main(),
              middle: Text('Music'),
              trailing: AccountData.instance.user == null ||
                      !ConnectionsCheck.instance.isOnline
                  ? null
                  : GestureDetector(
                      onTap: () async {
                        setState(() => updating = true);
                        await MusicDownloadData.instance.updateVKMusic(context);
                        setState(() => updating = false);
                      },
                      child: updating
                          ? CupertinoActivityIndicator()
                          : Icon(
                              SFSymbols.arrow_clockwise,
                              size: 20,
                            ),
                    ),
            ),
            child: Stack(children: <Widget>[
              _buildBody(),
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
                onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => VKAuthPage())))
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

  _buildBody() {
    return AccountData.instance.user != null &&
            (AccountData.instance.user.canUseVk ||
                AccountData.instance.user.isStaff)
        ? SafeArea(
            child: CustomScrollView(slivers: <Widget>[
            CupertinoSliverRefreshControl(onRefresh: () async {
              await MusicDownloadData.instance.loadMusic();

              setState(() {
                dataSongSorted = MusicDownloadData.instance.dataSong;
                _filterSongs(value: controller.text);
              });
            }),
            SliverList(
                delegate: SliverChildListDelegate(List.generate(
                    dataSongSorted.length +
                        (Utils.instance.playerUsing ? 2 : 1),
                    (index) => _buildSongListTile(index))))
          ]))
        : _provideData();
  }

  void _filterSongs({String value}) {
    if (value == null) {
      dataSongSorted = MusicDownloadData.instance.dataSong;
    } else if (value.isNotEmpty) {
      String newValue = value.toLowerCase();
      setState(() {
        dataSongSorted = MusicDownloadData.instance.dataSong
            .where((song) =>
                song.artist.toLowerCase().contains(newValue) ||
                song.title.toLowerCase().contains(newValue))
            .toList();
      });
    } else if (value.isEmpty) {
      setState(() {
        dataSongSorted = MusicDownloadData.instance.dataSong;
      });
    }
  }

  Widget _drawDownloadIcon(Song song) {
    return Container(
        color: Colors.transparent,
        transform: Matrix4.translationValues(-5, 0, 0),
        height: 60,
        width: 50,
        child: GestureDetector(
            onTap: song.downloaded
                ? null
                : () async {
                    if (MusicDownloadData.instance.inQuery(song)) {
                      await MusicDownloadData.instance.deleteFromQuery(song);
                    } else if (MusicDownloadData.instance.currentSong == song) {
                      await MusicDownloadData.instance.cancelDownload();
                    } else {
                      await MusicDownloadData.instance.addToQuery(song);
                    }
                  },
            child: song.downloaded
                ? Container(
                    transform: Matrix4.translationValues(-5, 0, 0),
                    child: Icon(SFSymbols.checkmark_alt, color: Colors.grey),
                  )
                : MusicDownloadData.instance.currentSong == song
                    ? Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: CircularPercentIndicator(
                          radius: 24.0,
                          lineWidth: 2.0,
                          backgroundColor: Colors.grey,
                          percent: MusicDownloadData.instance.progress,
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
                            color: MusicDownloadData.instance.inQuery(song)
                                ? HexColor.main()
                                : Colors.grey),
                      )));
  }

  _buildSongListTile(int index) {
    if (index == 0) {
      return AppleSearch(
          controller: controller,
          onChange: (value) => _filterSongs(value: value));
    }

    if (index >= dataSongSorted.length + 1) {
      return Container(height: 75);
    }

    Song song = dataSongSorted[index - 1];
    if (init) {
      _playerNotifyState =
          MusicDownloadData.instance.onResultChanged.listen((result) {
        if (result == DownloadState.COMPLETED)
          MusicData.instance.loadSavedMusic();
        MusicDownloadData.instance.showInfo(context, result);
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
                leading: _drawDownloadIcon(song),
                padding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () async {
                  bool isLocal = MusicData.instance.isLocal;
                  await MusicData.instance
                      .setPlaylistSongs(dataSongSorted, song, local: false);
                  if (MusicData.instance.currentSong != null &&
                      MusicData.instance.currentSong.songId == song.songId &&
                      !isLocal) {
                    await MusicData.instance.playerResume();
                  } else {
                    await MusicData.instance
                        .playerPlay(index: dataSongSorted.indexOf(song));
                  }
                },
                trailing: Text(song.formatDuration(),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          secondaryActions: <Widget>[
            SlideAction(
                color: HexColor('#d62d2d'),
                child: Icon(SFSymbols.trash, color: Colors.white),
                onTap: () async {
                  Api.hideMusic(song.songId);
                  setState(() {
                    MusicDownloadData.instance.dataSong.remove(song);
                    dataSongSorted = MusicDownloadData.instance.dataSong;
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
