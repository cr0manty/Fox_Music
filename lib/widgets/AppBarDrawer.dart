import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  bool _updating = false;

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
                child: new ListView(
              children: [
                new DrawerHeader(
                    child: new Row(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
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
                              newRouteName, (Route<dynamic> route) => false);
                        }
                      },
                      shape: new CircleBorder(),
                      child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              AssetImage('assets/images/user-default.jpg'))),
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
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.white),
                          )),
                      new Padding(
                          padding: const EdgeInsets.only(
                            left: 30,
                            top: 5,
                            right: 20,
                          ),
                          child: Text(
                            "Cr0manty",
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.white),
                          ))
                    ],
                  ))
                ])),
                new Divider(),
                new ListTile(
                  title: new Text('Update Music',
                      style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  leading: new Icon(Icons.update, color: Colors.white),
                  onTap: () async {
                    try {
                      _setUpdating();
                      final listNewSong = await requestMusicListPost();
                      if (listNewSong != null) {
                        infoDialog(context, "New songs",
                            "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
                      } else {
                        infoDialog(context, "Something went wrong",
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
                ),
                new ListTile(
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
                ),
                new ListTile(
                  title: new Text('People Search',
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
                ),
                new ListTile(
                  title: new Text('Download all',
                      style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  leading: new Icon(Icons.arrow_downward, color: Colors.white),
                  onTap: () async {
                    downloadAll(context);
                  },
                ),
                new Divider(),
                new ListTile(
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
                ),
              ],
            ))),
        inAsyncCall: _updating);
  }
}
