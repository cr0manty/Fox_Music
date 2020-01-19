import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/functions/get/getCurrentUser.dart';
import 'package:vk_parse/models/Song.dart';

import 'package:vk_parse/functions/save/logout.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/downloadAll.dart';
import 'package:vk_parse/utils/routes.dart';
import 'package:vk_parse/functions/get/getLastRoute.dart';
import 'package:vk_parse/functions/get/getPlayedSong.dart';

makeAppBar(String text, dynamic menuKey, {action}) {
  return AppBar(
      leading: new IconButton(
          icon: new Icon(Icons.menu),
          onPressed: () => menuKey.currentState.openDrawer()),
      title: Text(text),
      centerTitle: true,
      actions: action == null
          ? null
          : [
              IconButton(
                icon: Icon(Icons.edit),
              )
            ]);
}

class AppBarDrawer extends StatefulWidget {
  final AudioPlayer _audioPlayer;
  final bool offlineMode;

  AppBarDrawer(this._audioPlayer, {this.offlineMode});

  @override
  _AppBarDrawerState createState() =>
      _AppBarDrawerState(_audioPlayer, offlineMode);
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final AudioPlayer _audioPlayer;

  bool _updating = false;
  bool offlineMode;
  Song playedSong;
  var playerIcon = Icons.play_arrow;

  _AppBarDrawerState(this._audioPlayer, this.offlineMode) {
    offlineMode = offlineMode == null ? false : offlineMode;
  }

  _setUpdating() {
    setState(() {
      _updating = !_updating;
    });
  }

  _setPlayedSong() async {
    playedSong = await getPlayedSong();
  }

  @override
  void initState() {
    super.initState();
    _setPlayedSong();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_audioPlayer.state == AudioPlayerState.PLAYING) {
        playerIcon = Icons.pause;
      } else {
        playerIcon = Icons.play_arrow;
      }
    });
    return ModalProgressHUD(
        child: new Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color.fromRGBO(30, 30, 30, 0.7),
            ),
            child: new Drawer(
                key: _scaffoldKey,
                child: new IntrinsicHeight(
                    child: Column(
                  children: [
                    _profileBuild(),
                    _searchBuild(),
                    _musicListBuild(),
                    _friendsBuild(),
                    new Divider(),
                    _updateMusicBuild(),
                    _downloadAllBuild(),
                    new Divider(),
                    _logoutBuild(),
                    _playerBuild(),
                  ],
                )))),
        inAsyncCall: _updating);
  }

  _playerBuild() {
    return new Expanded(
      child: new Align(
          alignment: Alignment.bottomCenter,
          child: new Container(
              width: double.infinity,
              color: Color.fromRGBO(25, 25, 25, 0.85),
              padding: new EdgeInsets.all(1.5),
              child: new ListTile(
                leading: new IconButton(
                  icon: Icon(playerIcon, size: 35, color: Colors.white70),
                  onPressed: () {
                    if (_audioPlayer.state == AudioPlayerState.PLAYING) {
                      _audioPlayer.pause();
                      setState(() {
                        playerIcon = Icons.play_arrow;
                      });
                    } else {
                      _audioPlayer.resume();
                      setState(() {
                        playerIcon = Icons.pause;
                      });
                    }
                  },
                ),
              ))),
    );
  }

  _profileBuild() {
    return new DrawerHeader(
        child: new Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new FlatButton(
          onPressed: offlineMode
              ? null
              : () async {
                  final lastRoute = await getLastRoute();
                  final user = await getLastUser();
                  if (lastRoute != 2) {
                    await Navigator.of(context).pop();
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => switchRoutes(
                            _audioPlayer,
                            offline: offlineMode,
                            route: 2,
                            user: user)));
                  }
                },
          shape: new CircleBorder(),
          child: new CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: AssetImage('assets/images/user-default.jpg'))),
      new Center(
          child: new Column(
        children: <Widget>[
          new Padding(
              padding: const EdgeInsets.only(
                left: 40,
                top: 30,
                right: 20,
              ),
              child: Text(
                "Denis",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              )),
          new Padding(
              padding: const EdgeInsets.only(
                left: 30,
                top: 5,
                right: 20,
              ),
              child: Text(
                "Cr0manty",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ))
        ],
      ))
    ]));
  }

  _musicListBuild() {
    return new ListTile(
      title: new Text('Music',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.music_note, color: Colors.white),
      onTap: offlineMode
          ? null
          : () async {
              final lastRoute = await getLastRoute();
              if (lastRoute != 1) {
                await Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => switchRoutes(
                        _audioPlayer,
                        offline: offlineMode,
                        route: 1)));
              }
            },
    );
  }

  _friendsBuild() {
    return new ListTile(
      title: new Text('Friends',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.people, color: Colors.white),
      onTap: offlineMode
          ? null
          : () async {
              final lastRoute = await getLastRoute();
              if (lastRoute != 3) {
                await Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => switchRoutes(
                        _audioPlayer,
                        offline: offlineMode,
                        route: 3)));
              }
            },
    );
  }

  _searchBuild() {
    return new ListTile(
      title: new Text('Search',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.search, color: Colors.white),
      onTap: true || offlineMode
          ? null
          : () async {
              final lastRoute = await getLastRoute();
              if (lastRoute != -1) {
                await Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => switchRoutes(
                        _audioPlayer,
                        offline: offlineMode,
                        route: -1)));
              }
            },
    );
  }

  _updateMusicBuild() {
    return new ListTile(
      title: new Text('Update Music',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.update, color: Colors.white),
      onTap: () async {
        try {
          _setUpdating();
          final listNewSong = await requestMusicListPost();
          if (listNewSong != null) {
            infoDialog(_scaffoldKey.currentContext, "New songs",
                "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
          } else {
            infoDialog(_scaffoldKey.currentContext, "Something went wrong",
                "Unable to get Music List.");
          }
        } catch (e) {
          print(e);
        } finally {
          _setUpdating();
        }
      },
    );
  }

  _downloadAllBuild() {
    return new ListTile(
      title: new Text('Download all',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.arrow_downward, color: Colors.white),
      onTap: () async {
        try {
          final downloadAmount = await downloadAll();
          if (downloadAmount > -1)
            infoDialog(_scaffoldKey.currentContext, "Downloader",
                "$downloadAmount songs downloaded");
          else if (downloadAmount == -1) {
            infoDialog(_scaffoldKey.currentContext, "Downloader Error",
                "Can't connect to VK servers, try to use VPN or Proxy.");
          } else if (downloadAmount == -2) {
            infoDialog(
                _scaffoldKey.currentContext, "Ooops", "Smth went wrong.");
          }
        } catch (e) {
          infoDialog(_scaffoldKey.currentContext, "Ooops", "Smth went wrong.");
        } finally {}
      },
    );
  }

  _logoutBuild() {
    return new ListTile(
      title: new Text('Logout',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.exit_to_app, color: Colors.white),
      onTap: () {
        logout();
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => switchRoutes(_audioPlayer)));
      },
    );
  }
}
