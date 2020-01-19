import 'package:flutter/material.dart';

import 'package:vk_parse/widgets/MusicListRequest.dart';
import 'package:vk_parse/widgets/MusicListSaved.dart';
import 'package:vk_parse/widgets/AppBarDrawer.dart';

import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicList extends StatefulWidget {
  final AudioPlayer _audioPlayer;
  final bool offlineMode;

  MusicList(this._audioPlayer, {this.offlineMode});

  @override
  State<StatefulWidget> createState() =>
      new MusicListState(_audioPlayer, offlineMode);
}

class MusicListState extends State<MusicList> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  final AudioPlayer _audioPlayer;
  bool offlineMode;

  MusicListState(this._audioPlayer, this.offlineMode) {
    offlineMode = offlineMode == null ? false : offlineMode;
    saveCurrentRoute(route: 1);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _menuKey,
          drawer: AppBarDrawer(_audioPlayer, offlineMode: offlineMode),
          backgroundColor: lightGrey,
          appBar: AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.menu),
                onPressed: () => _menuKey.currentState.openDrawer()),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Music List',
                ),
                Tab(
                  text: 'Saved Music',
                ),
                Tab(
                  text: 'Music Search',
                ),
              ],
            ),
            title: Text('Music'),
          ),
          body: TabBarView(
            children: [
              offlineMode
                  ? Icon(Icons.not_interested)
                  : MusicListRequest(_audioPlayer),
              MusicListSaved(_audioPlayer),
              Icon(Icons.not_interested),
            ],
          ),
        ));
  }
}
