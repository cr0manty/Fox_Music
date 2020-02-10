import 'package:flutter/material.dart';
import 'package:vk_parse/models/AccountData.dart';
import 'package:vk_parse/ui/LoginPage.dart';
import 'package:vk_parse/ui/PlayerPage.dart';
import 'package:vk_parse/ui/PlaylistPage.dart';

import 'package:provider/provider.dart';
import 'package:vk_parse/models/MusicData.dart';

import 'package:vk_parse/ui/MusicListPage.dart';
import 'package:vk_parse/ui/AccountPage.dart';
import 'package:vk_parse/ui/VKMusicListPage.dart';

class MainPage extends StatelessWidget {
  _buildView(MusicData data, child) {
    return ChangeNotifierProvider<MusicData>.value(value: data, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final _sharedData = Provider.of<MusicData>(context);
    final _accountData = Provider.of<AccountData>(context);

    return DefaultTabController(
        length: 5,
        child: new Scaffold(
          body: TabBarView(
            children: [
              _buildView(_sharedData, PlaylistPage()),
              _buildView(_sharedData, MusicListPage(_sharedData.localSongs)),
              _buildView(_sharedData, PlayerPage()),
              _buildView(_sharedData, VKMusicListPage()),
              _buildView(
                  _sharedData,
                  _accountData.user != null ? AccountPage() : LoginPage())
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
                      icon: new Icon(Icons.music_note, size: 35),
                    ),
                    Tab(
                      icon: new Icon(Icons.perm_identity, size: 35),
                    )
                  ],
                  labelColor: Colors.redAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 0.1)),
          backgroundColor: Color.fromRGBO(25, 25, 25, 0.8),
        ));
  }
}
