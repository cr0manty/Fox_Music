import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/functions/save/last_tab.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Account/sign_in.dart';
import 'package:fox_music/ui/Music/player.dart';
import 'package:fox_music/ui/Music/playlist.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/ui/Music/music_list.dart';
import 'package:fox_music/ui/Account/account.dart';
import 'package:fox_music/ui/Music/online_music.dart';
import 'package:fox_music/utils/swipe_detector.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class MainPage extends StatefulWidget {
  final int lastIndex;

  MainPage(this.lastIndex);

  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  int currentIndex = 0;
  bool keyboardActive = false;

  @override
  void initState() {
    currentIndex = widget.lastIndex;
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardActive = visible;
      },
    );
    super.initState();
  }

  Widget _buildView(MusicData musicData, AccountData accountData,
      MusicDownloadData downloadData, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<MusicData>.value(value: musicData),
      ChangeNotifierProvider<MusicDownloadData>.value(value: downloadData),
      ChangeNotifierProvider<AccountData>.value(value: accountData),
    ], child: child);
  }

  Widget _switchTabs(MusicData musicData, MusicDownloadData downloadData,
      AccountData accountData, int index) {
    Widget page;
    saveLastTab(index);

    switch (index) {
      case 0:
        page = ChangeNotifierProvider<MusicData>.value(
            value: musicData,
            child: CupertinoTabView(
                builder: (BuildContext context) => PlaylistPage()));
        break;
      case 1:
        page = CupertinoTabView(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<MusicData>.value(
                    value: musicData, child: MusicListPage()));
        break;
      case 2:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                musicData, accountData, downloadData, OnlineMusicListPage()));
        break;
      case 3:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                musicData,
                accountData,
                downloadData,
                accountData.user != null ? AccountPage() : SignIn()));
        break;
    }

    return Stack(
      children: <Widget>[page, _buildPlayer(musicData)],
    );
  }

  Widget _buildPlayer(MusicData musicData) {
    double duration = MediaQuery.of(context).size.width *
        (durToInt(musicData.songPosition) / durToInt(musicData.songDuration));
    return musicData.currentSong != null && !keyboardActive
        ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Container(
                    color: main_color,
                    width: duration,
                    height: 2,
                  ),
                  SwipeDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .push(BottomRoute(
                              page: ChangeNotifierProvider<MusicData>.value(
                                  value: musicData, child: PlayerPage()))),
                      onSwipeUp: () => Navigator.of(context, rootNavigator: true)
                          .push(BottomRoute(
                              page: ChangeNotifierProvider<MusicData>.value(
                                  value: musicData, child: PlayerPage()))),
                      onSwipeDown: () {
                        musicData.playerStop();
                        setState(() {
                          musicData.currentSong = null;
                        });
                      },
                      child: ClipRect(
                          child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black26.withOpacity(0.3)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    children: <Widget>[
                                      Container(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            musicData.currentSong.title,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Divider(
                                            height: 5,
                                          ),
                                          Text(
                                            musicData.currentSong.artist,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: SizedBox()),
                                      GestureDetector(
                                        child: Container(
                                            color: Colors.transparent,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            child: Icon(
                                              musicData.playerState ==
                                                      AudioPlayerState.PLAYING
                                                  ? SFSymbols.pause_fill
                                                  : SFSymbols.play_fill,
                                              color: Colors.white,
                                              size: 20,
                                            )),
                                        onTap: () => musicData.playerState ==
                                                AudioPlayerState.PLAYING
                                            ? musicData.playerPause()
                                            : musicData.playerResume(),
                                      ),
                                      GestureDetector(
                                        child: Container(
                                            color: Colors.transparent,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            child: Icon(
                                              SFSymbols.forward_fill,
                                              size: 20,
                                              color: Colors.white,
                                            )),
                                        onTap: () => musicData.next(),
                                      )
                                    ],
                                  )))))
                ])))
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    AccountData accountData = Provider.of<AccountData>(context);

    return WillPopScope(
        onWillPop: () => Future<bool>.value(true),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              activeColor: main_color,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.music_note_list),
                    title: Text('Playlist')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.folder), title: Text('Media')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.music_note_2), title: Text('Music')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.person_alt), title: Text('Account'))
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _switchTabs(musicData, downloadData, accountData, index);
            }));
  }
}
