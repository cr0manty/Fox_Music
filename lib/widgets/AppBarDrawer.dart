import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:audioplayers/audioplayers.dart';

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
  @override
  _AppBarDrawerState createState() => _AppBarDrawerState();
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AudioPlayer _audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
  bool _updating = false;
  var playerIcon = Icons.play_arrow;

  _setUpdating() {
    setState(() {
      _updating = !_updating;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    new DrawerHeader(
                        child: new Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                          FlatButton(
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
                                      newRouteName,
                                      (Route<dynamic> route) => false);
                                }
                              },
                              shape: new CircleBorder(),
                              child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: AssetImage(
                                      'assets/images/user-default.jpg'))),
                          Center(
                              child: Column(
                            children: <Widget>[
                              new Padding(
                                  padding: const EdgeInsets.only(
                                    left: 40,
                                    top: 30,
                                    right: 20,
                                  ),
                                  child: Text(
                                    "Denis",
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  )),
                              new Padding(
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                    top: 5,
                                    right: 20,
                                  ),
                                  child: Text(
                                    "Cr0manty",
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  ))
                            ],
                          ))
                        ])),
                    new ListTile(
                      title: new Text('Music',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
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
                    ),
                    new ListTile(
                      title: new Text('Friends',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
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
                    ),
                    new ListTile(
                      title: new Text('People Search',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
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
                                    newRouteName,
                                    (Route<dynamic> route) => false);
                              }
                            },
                    ),
                    new Divider(),
                    new ListTile(
                      title: new Text('Update Music',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
                      leading: new Icon(Icons.update, color: Colors.white),
                      onTap: () async {
                        try {
                          _setUpdating();
                          final listNewSong = await requestMusicListPost();
                          if (listNewSong != null) {
                            infoDialog(_scaffoldKey.currentContext, "New songs",
                                "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
                          } else {
                            infoDialog(
                                _scaffoldKey.currentContext,
                                "Something went wrong",
                                "Unable to get Music List.");
                          }
                        } catch (e) {
                          print(e);
                        } finally {
                          _setUpdating();
                        }
                      },
                    ),
                    new ListTile(
                      title: new Text('Download all',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
                      leading:
                          new Icon(Icons.arrow_downward, color: Colors.white),
                      onTap: () async {
                        try {
                          final downloadAmount = await downloadAll();
                          if (downloadAmount > -1)
                            infoDialog(
                                _scaffoldKey.currentContext,
                                "Downloader",
                                "$downloadAmount songs downloaded");
                          else if (downloadAmount == -1) {
                            infoDialog(
                                _scaffoldKey.currentContext,
                                "Downloader Error",
                                "Can't connect to VK servers, try to use VPN or Proxy.");
                          } else if (downloadAmount == -2) {
                            infoDialog(_scaffoldKey.currentContext, "Ooops",
                                "Smth went wrong.");
                          }
                        } catch (e) {
                          infoDialog(_scaffoldKey.currentContext, "Ooops",
                              "Smth went wrong.");
                        } finally {}
                      },
                    ),
                    new Divider(),
                    new ListTile(
                      title: new Text('Logout',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.white)),
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
                    ),
                    new Expanded(
                        child: new Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                          width: double.infinity,
                          color: Color.fromRGBO(25, 25, 25, 0.85),
                          padding: new EdgeInsets.all(1.5),
                          child: new ListTile(
                              leading: new Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                new IconButton(
                                  icon: Icon(Icons.skip_previous,
                                      size: 35, color: Colors.white70),
                                  onPressed: null,
                                ),
                                new IconButton(
                                  icon: Icon(playerIcon,
                                      size: 35, color: Colors.white70),
                                  onPressed: () {
                                    if (_audioPlayer.state ==
                                        AudioPlayerState.PLAYING) {
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
                                new IconButton(
                                  icon: Icon(Icons.skip_next,
                                      size: 35, color: Colors.white70),
                                  onPressed: null,
                                ),
                              ]))),
                    )),
                  ],
                )))),
        inAsyncCall: _updating);
  }
}
