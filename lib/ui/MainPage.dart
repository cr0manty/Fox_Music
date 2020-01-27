import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/api/requestProfile.dart';
import 'package:vk_parse/functions/get/getCurrentUser.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/ui/Login.dart';
import 'package:vk_parse/ui/Player.dart';
import 'package:vk_parse/ui/Playlists.dart';

import 'package:vk_parse/widgets/MusicListSaved.dart';
import 'package:vk_parse/ui/Account.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AudioPlayer _audioPlayer =
      AudioPlayer(playerId: 'usingThisIdForPlayer');
  User _user;

  _getUser() async {
    final user = await requestProfileGet();
    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: new Scaffold(
          body: TabBarView(
            children: [
              PlaylistPage(_audioPlayer),
              MusicListSaved(_audioPlayer),
              Player(_audioPlayer),
              _user != null ? Account(_user) : Login(),
              Container(
                color: Color.fromRGBO(35, 35, 35, 1),
              ),
            ],
          ),
          bottomNavigationBar: Container(
              child: new TabBar(
                  tabs: [
                Tab(
                  icon: new Icon(Icons.playlist_play, size: 35),
                ),
                Tab(
                  icon: new Icon(Icons.folder, size: 35),
                ),
                Tab(
                  icon: new Icon(Icons.play_circle_outline, size: 45),
                ),
                Tab(
                  icon: new Icon(Icons.perm_identity, size: 35),
                ),
                Tab(
                  icon: new Icon(Icons.settings, size: 35),
                )
              ],
                  labelColor: Colors.redAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 0.1)),
          backgroundColor: Color.fromRGBO(25, 25, 25, 0.8),
        ));
  }
}
