import 'package:flutter/material.dart';
import 'package:vk_parse/models/AccountData.dart';
import 'package:vk_parse/ui/Account/LoginPage.dart';
import 'package:vk_parse/ui/Music/PlayerPage.dart';
import 'package:vk_parse/ui/Music/PlaylistPage.dart';

import 'package:provider/provider.dart';
import 'package:vk_parse/models/MusicData.dart';

import 'package:vk_parse/ui/Music/MusicListPage.dart';
import 'package:vk_parse/ui/Account/AccountPage.dart';
import 'package:vk_parse/ui/Music/VKMusicListPage.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _currentPage;
  MusicData musicData;
  AccountData accountData;
  int currentIndex = 0;

  _buildView(MusicData musicData, AccountData accountData, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<MusicData>.value(value: musicData),
      ChangeNotifierProvider<AccountData>.value(value: accountData),
    ], child: child);
  }

  _switchPages(MusicData musicData, AccountData accountData, int index) {
    switch (index) {
      case 0:
        return ChangeNotifierProvider<MusicData>.value(
            value: musicData, child: PlaylistPage());
        break;
      case 1:
        return ChangeNotifierProvider<MusicData>.value(
            value: musicData, child: MusicListPage(musicData.localSongs));
        break;
      case 2:
        return ChangeNotifierProvider<MusicData>.value(
            value: musicData, child: PlayerPage());
        break;
      case 3:
        return _buildView(musicData, accountData, VKMusicListPage());
        break;
      case 4:
        return _buildView(musicData, accountData,
            accountData.user != null ? AccountPage() : LoginPage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    AccountData accountData = Provider.of<AccountData>(context);

    setState(() {
      _currentPage = _switchPages(musicData, accountData, currentIndex);
    });

    return Scaffold(
        body: _currentPage,
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              _currentPage = _switchPages(musicData, accountData, currentIndex);
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: new Icon(Icons.playlist_play, size: 40),
                title: Text('Playlist')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.folder, size: 40), title: Text('Media')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.play_circle_outline, size: 50),
                title: Text('Player')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.music_note, size: 40),
                title: Text('Music')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.perm_identity, size: 40),
                title: Text('Account'))
          ],
          selectedIconTheme: IconThemeData(color: Colors.redAccent),
        ));
  }
}
