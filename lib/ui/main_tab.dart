import 'dart:async';
import 'dart:ui';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/functions/save/last_tab.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Account/sign_in.dart';
import 'package:fox_music/ui/Music/player.dart';
import 'package:fox_music/ui/Music/playlist.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/check_connection.dart';
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
  final MusicData musicData;
  final MusicDownloadData downloadData;
  final AccountData accountData;
  final int lastIndex;
  final ConnectionsCheck connection;

  MainPage(
      {this.lastIndex,
      this.downloadData,
      this.musicData,
      this.accountData,
      this.connection});

  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> offset;
  CupertinoTabController controller;
  StreamSubscription _showPlayer;
  StreamSubscription _isPlaying;
  StreamSubscription _loginIn;
  bool keyboardActive = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    controller = CupertinoTabController(
        initialIndex: widget.lastIndex < 0 ? 0 : widget.lastIndex);
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(animationController);
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardActive = visible;
      },
    );
    controller.addListener(() async {
      saveLastTab(controller.index);
    });

    _showPlayer = widget.musicData.onPlayerActive.listen((active) {
      if (active) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });

    _isPlaying = widget.musicData.onPlayerChangeState.listen((state) {
      setState(() {
        isPlaying = state;
      });
    });

    _loginIn = widget.accountData.onUserChangeAccount.listen((value) {
      setState(() {});
    });
    animationController.forward();
    WidgetsBinding.instance.addObserver(this);
  }

  Widget _buildView(Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<MusicDownloadData>.value(
          value: widget.downloadData),
      ChangeNotifierProvider<ConnectionsCheck>.value(value: widget.connection),
      ChangeNotifierProvider<AccountData>.value(value: widget.accountData),
    ], child: child);
  }

  Widget _switchTabs(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = ChangeNotifierProvider<MusicDownloadData>.value(
            value: widget.downloadData,
            child: CupertinoTabView(
                builder: (BuildContext context) => PlaylistPage()));
        break;
      case 1:
        page = CupertinoTabView(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<MusicDownloadData>.value(
                    value: widget.downloadData, child: MusicListPage()));
        break;
      case 2:
        page = CupertinoTabView(
            builder: (BuildContext context) =>
                _buildView(OnlineMusicListPage()));
        break;
      case 3:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                widget.accountData.user != null
                    ? AccountPage(widget.connection.isOnline)
                    : SignIn()));
        break;
    }
    return Stack(children: <Widget>[page, _buildPlayer()]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        isPlaying = AudioManager.instance.isPlaying;
      });
    }
  }

  Widget _buildPlayer() {
    return !keyboardActive
        ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
                position: offset,
                child: SafeArea(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SwipeDetector(
                            onTap: () => Navigator.of(context, rootNavigator: true)
                                .push(BottomRoute(
                                    page:
                                        ChangeNotifierProvider<MusicData>.value(
                                            value: widget.musicData,
                                            child: PlayerPage()))),
                            onSwipeUp: () => Navigator.of(context,
                                    rootNavigator: true)
                                .push(BottomRoute(
                                    page:
                                        ChangeNotifierProvider<MusicData>.value(
                                            value: widget.musicData,
                                            child: PlayerPage()))),
                            onSwipeDown: () async {
                              await widget.musicData.playerStop();
                              animationController.forward();
                            },
                            child: ClipRect(
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: Container(
                                        decoration: BoxDecoration(color: Colors.black26.withOpacity(0.22)),
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Container(
                                                    color: Colors.transparent,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.12,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.12,
                                                    child: isPlaying == null
                                                        ? CupertinoActivityIndicator()
                                                        : Icon(
                                                            isPlaying
                                                                ? SFSymbols
                                                                    .pause_fill
                                                                : SFSymbols
                                                                    .play_fill,
                                                            color: Colors.white,
                                                            size: 20,
                                                          )),
                                                onTap: () => AudioManager
                                                        .instance.isPlaying
                                                    ? widget.musicData
                                                        .playerPause()
                                                    : widget.musicData
                                                        .playerResume()),
                                            SizedBox(width: 10),
                                            Flexible(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  AudioManager.instance.info
                                                              ?.title !=
                                                          null
                                                      ? AudioManager
                                                          .instance.info.title
                                                      : '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Divider(
                                                  height: 5,
                                                ),
                                                Text(
                                                  AudioManager.instance.info
                                                              ?.desc !=
                                                          null
                                                      ? AudioManager
                                                          .instance.info.desc
                                                      : '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            )),
                                            SizedBox(),
                                            GestureDetector(
                                                child: Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    color: Colors.transparent,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.12,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.12,
                                                    child: Icon(
                                                      SFSymbols.forward_fill,
                                                      size: 20,
                                                      color: Colors.white,
                                                    )),
                                                onTap: () =>
                                                    widget.musicData.next())
                                          ],
                                        )))))
                      ]),
                )))
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoTabScaffold(
            controller: controller,
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
            tabBuilder: _switchTabs));
  }

  @override
  void dispose() {
    _showPlayer?.cancel();
    _isPlaying?.cancel();
    _loginIn?.cancel();
    controller.dispose();
    animationController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
