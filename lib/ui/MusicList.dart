import 'package:flutter/material.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

import 'package:vk_parse/widgets/MusicListRequest.dart';
import 'package:vk_parse/widgets/MusicListSaved.dart';
import 'package:vk_parse/widgets/AppBarDrawer.dart';

import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/utils/colors.dart';

class MusicList extends StatefulWidget {
  final RmxAudioPlayer _audioPlayer;
  final bool _offline;

  MusicList(this._audioPlayer, this._offline);

  @override
  State<StatefulWidget> createState() =>
      new MusicListState(_audioPlayer, _offline);
}

class MusicListState extends State<MusicList> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  final RmxAudioPlayer _audioPlayer;
  final bool _offline;

  MusicListState(this._audioPlayer, this._offline);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _menuKey,
          drawer: AppBarDrawer(_audioPlayer, _offline),
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
              _offline
                  ? Icon(Icons.not_interested)
                  : MusicListRequest(_audioPlayer),
              MusicListSaved(_audioPlayer),
              Icon(Icons.not_interested),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute(route: 1);
  }
}
