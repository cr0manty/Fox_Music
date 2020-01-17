import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

import 'package:vk_parse/functions/save/logout.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/utils/downloadAll.dart';

makeAppBar(String text, dynamic menuKey) {
  return AppBar(
    leading: new IconButton(
        icon: new Icon(Icons.menu),
        onPressed: () => menuKey.currentState.openDrawer()),
    title: Text(text),
    centerTitle: true,
  );
}

class AppBarDrawer extends StatefulWidget {
  final RmxAudioPlayer _audioPlayer;
  final bool _offline;
  AppBarDrawer(this._audioPlayer, this._offline);

  @override
  _AppBarDrawerState createState() => _AppBarDrawerState(_audioPlayer, _offline);
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final RmxAudioPlayer _audioPlayer;
  final bool _offline;

  bool _updating = false;
  var playerIcon = Icons.play_arrow;

  _AppBarDrawerState(this._audioPlayer, this._offline);

  _setUpdating() {
    setState(() {
      _updating = !_updating;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_audioPlayer.isPlaying) {
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
                    _musicListBuild(),
                    _friendsBuild(),
                    _searchBuild(),
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
              leading: new Row(mainAxisSize: MainAxisSize.min, children: [
            new IconButton(
              icon: Icon(Icons.skip_previous, size: 35, color: Colors.white70),
              onPressed: null,
            ),
            new IconButton(
              icon: Icon(playerIcon, size: 35, color: Colors.white70),
              onPressed: () {
                if (_audioPlayer.isPlaying) {
                  _audioPlayer.pause();
                  setState(() {
                    playerIcon = Icons.play_arrow;
                  });
                } else  if(_audioPlayer.isStopped || _audioPlayer.isPaused){
                  _audioPlayer.play();
                  setState(() {
                    playerIcon = Icons.pause;
                  });
                }
              },
            ),
            new IconButton(
              icon: Icon(Icons.skip_next, size: 35, color: Colors.white70),
              onPressed: null,
            ),
          ]))),
    ));
  }

  _profileBuild() {
    return new DrawerHeader(
        child: new Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new FlatButton(
          onPressed: () {
            final newRouteName = "/Account";
            bool isNewRouteSameAsCurrent = false;
            Navigator.popUntil(context, (route) {
              if (route.settings.name == newRouteName) {
                isNewRouteSameAsCurrent = true;
              }
              return true;
            });
            if (!isNewRouteSameAsCurrent) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  newRouteName, (Route<dynamic> route) => false);
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
      leading: new Icon(Icons.wifi, color: Colors.white),
      onTap: () {
        final newRouteName = "/MusicList";
        bool isNewRouteSameAsCurrent = false;

        Navigator.popUntil(context, (route) {
          if (route.settings.name == newRouteName) {
            isNewRouteSameAsCurrent = true;
          }
          return true;
        });

        if (!isNewRouteSameAsCurrent) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              newRouteName, (Route<dynamic> route) => false);
        }
      },
    );
  }

  _friendsBuild() {
    return new ListTile(
      title: new Text('Friends',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.people, color: Colors.white),
      onTap: () {
        final newRouteName = "/FriendList";
        bool isNewRouteSameAsCurrent = false;

        Navigator.popUntil(context, (route) {
          if (route.settings.name == newRouteName) {
            isNewRouteSameAsCurrent = true;
          }
          return true;
        });
        if (!isNewRouteSameAsCurrent) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              newRouteName, (Route<dynamic> route) => false);
        }
      },
    );
  }

  _searchBuild() {
    return new ListTile(
      title: new Text('Search',
          style: TextStyle(fontSize: 15.0, color: Colors.white)),
      leading: new Icon(Icons.search, color: Colors.white),
      onTap: true
          ? null
          : () {
              final newRouteName = "/PeopleSearch";
              bool isNewRouteSameAsCurrent = false;

              Navigator.popUntil(context, (route) {
                if (route.settings.name == newRouteName) {
                  isNewRouteSameAsCurrent = true;
                }
                return true;
              });
              if (!isNewRouteSameAsCurrent) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    newRouteName, (Route<dynamic> route) => false);
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
        final newRouteName = "/Login";
        bool isNewRouteSameAsCurrent = false;

        Navigator.popUntil(context, (route) {
          if (route.settings.name == newRouteName) {
            isNewRouteSameAsCurrent = true;
          }
          return true;
        });
        if (!isNewRouteSameAsCurrent) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              newRouteName, (Route<dynamic> route) => false);
        }
      },
    );
  }
}
