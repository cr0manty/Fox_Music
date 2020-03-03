import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:vk_parse/provider/AccountData.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
import 'package:vk_parse/ui/Account/LoginPage.dart';
import 'package:vk_parse/ui/Music/PlayerPage.dart';
import 'package:vk_parse/ui/Music/PlaylistPage.dart';

import 'package:provider/provider.dart';
import 'package:vk_parse/provider/MusicData.dart';

import 'package:vk_parse/ui/Music/MusicListPage.dart';
import 'package:vk_parse/ui/Account/AccountPage.dart';
import 'package:vk_parse/ui/Music/VKMusicListPage.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  int currentIndex = 0;

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
                musicData, accountData, downloadData, VKMusicListPage()));
        break;
      case 3:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                musicData,
                accountData,
                downloadData,
                accountData.user != null ? AccountPage() : LoginPage()));
        break;
    }
    return Stack(
      children: <Widget>[page, _buildPlayer(musicData)],
    );
  }

  Widget _buildPlayer(MusicData musicData) {
    return musicData.currentSong != null
        ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ChangeNotifierProvider<MusicData>.value(
                                value: musicData, child: PlayerPage()),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ));
                    },
                    child: SwipeDetector(
                        onSwipeDown: () {
                          musicData.playerStop();
                          setState(() {
                            musicData.currentSong = null;
                          });
                        },
                        child: ClipRect(
                            child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black26.withOpacity(0.3)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey,
                                        ),
                                        Container(width: 25),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              musicData.currentSong.title,
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                          child: Icon(
                                            musicData.playerState ==
                                                    AudioPlayerState.PLAYING
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          onTap: () => musicData.playerState ==
                                                  AudioPlayerState.PLAYING
                                              ? musicData.playerPause()
                                              : musicData.playerResume(),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.skip_next,
                                            color: Colors.white,
                                          ),
                                          onTap: () => musicData.next(),
                                        )
                                      ],
                                    ))))))))
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
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.playlist_play), title: Text('Playlist')),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.folder_open),
                    title: Text('Media')),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.music_note),
                    title: Text('Music')),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person), title: Text('Account'))
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _switchTabs(musicData, downloadData, accountData, index);
            }));
  }
}
