import 'package:flutter/material.dart';
import 'package:vk_parse/ui/Login.dart';
import 'package:vk_parse/ui/Player.dart';
import 'package:vk_parse/ui/Playlists.dart';

import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:vk_parse/widgets/MusicListSaved.dart';
import 'package:vk_parse/ui/Account.dart';

class MainPage extends StatelessWidget {
  _buildView(ProjectData data, child) {
    return ChangeNotifierProvider<ProjectData>.value(
        value: data, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final _sharedData = Provider.of<ProjectData>(context);
    return DefaultTabController(
        length: 5,
        child: new Scaffold(
          body: TabBarView(
            children: [
              _buildView(_sharedData, PlaylistPage()),
              _buildView(_sharedData, MusicListSaved()),
              _buildView(_sharedData, Player()),
              _buildView(_sharedData, _sharedData.user != null ? Account() : Login()),
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
