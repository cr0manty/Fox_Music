import 'dart:async';
import 'dart:ui';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/instances/account_data.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/instances/utils.dart';
import 'package:fox_music/ui/Account/sign_in.dart';
import 'package:fox_music/ui/Music/player.dart';
import 'package:fox_music/ui/Music/playlist.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/ui/Music/music_list.dart';
import 'package:fox_music/ui/Account/account.dart';
import 'package:fox_music/ui/Music/online_music.dart';
import 'package:fox_music/widgets/swipe_detector.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> offset;
  CupertinoTabController controller;
  StreamSubscription _showPlayer;
  StreamSubscription _isPlaying;
  StreamSubscription _loginIn;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    Utils.instance.cache();

    controller = CupertinoTabController(
        initialIndex:
            SharedPrefs.getLastTab() < 0 ? 0 : SharedPrefs.getLastTab());
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 350), value: 1);
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(animationController);

    controller.addListener(() async {
      SharedPrefs.saveLastTab(controller.index);
    });

    _showPlayer = MusicData.instance.onPlayerActive.listen((active) {
      if (active) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });

    _isPlaying = MusicData.instance.onPlayerChangeState.listen((state) {
      setState(() {
        isPlaying = state;
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Widget _switchTabs(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page =
            CupertinoTabView(builder: (BuildContext context) => PlaylistPage());
        break;
      case 1:
        page = CupertinoTabView(
            builder: (BuildContext context) => MusicListPage());
        break;
      case 2:
        page = CupertinoTabView(
            builder: (BuildContext context) => OnlineMusicListPage());
        break;
      case 3:
        page = CupertinoTabView(
            builder: (BuildContext context) =>
                AccountData.instance.user != null ? AccountPage() : SignIn());
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
    return !Utils.instance.keyboardActive
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
                            onTap: () => KeyHolder()
                                .key
                                .currentState
                                .push(BottomRoute(page: PlayerPage())),
                            onSwipeUp: () => KeyHolder()
                                .key
                                .currentState
                                .push(BottomRoute(page: PlayerPage())),
                            onSwipeDown: () async {
                              await MusicData.instance.playerStop();
                              animationController.forward();
                            },
                            child: ClipRect(
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black26
                                                .withOpacity(0.22)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
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
                                                    ? MusicData.instance
                                                        .playerPause()
                                                    : MusicData.instance
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
                                                    MusicData.instance.next())
                                          ],
                                        )))))
                      ]),
                )))
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    Utils.instance.checkVersion(context);

    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoTabScaffold(
            controller: controller,
            tabBar: CupertinoTabBar(
              activeColor: HexColor.main(),
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
