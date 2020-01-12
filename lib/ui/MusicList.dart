import 'package:flutter/material.dart';

import 'package:vk_parse/widgets/MusicListRequest.dart';
import 'package:vk_parse/widgets/MusicListSaved.dart';
import 'package:vk_parse/widgets/AppBarDrawer.dart';

import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/utils/colors.dart';

class MusicList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MusicListState();
  }
}

class MusicListState extends State<MusicList> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _menuKey,
          drawer: AppBarDrawer(),
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
              MusicListRequest(),
              MusicListSaved(),
              Icon(Icons.not_interested),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute('/MusicList');
  }
}
