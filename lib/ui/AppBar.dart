import 'package:flutter/material.dart';

import 'package:vk_parse/functions/save/logout.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

makeDrawer(context) {
  return new Drawer(
      child: new ListView(
    children: <Widget>[
      new DrawerHeader(
          child: new Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                backgroundImage: NetworkImage(
                    'https://shara-games.ru/uploads/posts/2016-07/thumbs/1467462542_katarina-1.jpg'))),
        Center(
            child: Column(
          children: <Widget>[
            new Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  top: 20,
                  right: 20,
                ),
                child: Text(
                  "Denis",
                  style: TextStyle(fontSize: 18.0),
                )),
            new Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  top: 5,
                  right: 20,
                ),
                child: Text(
                  "Cr0manty",
                  style: TextStyle(fontSize: 18.0),
                ))
          ],
        ))
      ])),
      new ListTile(
        title: new Text('Update music list'),
        leading: new Icon(Icons.update),
        onTap: () async {
          try {
            final listNewSong = await requestMusicListPost(context);
            infoDialog(context, "New songs",
                "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
          } catch (e) {
            print(e);
          }
        },
      ),
      new ListTile(
        title: new Text('Music List'),
        leading: new Icon(Icons.wifi),
        onTap: () {
          final newRouteName = "/MusicListRequest";
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
        title: new Text('Saved music list'),
        leading: new Icon(Icons.save),
        onTap: () {
          final newRouteName = "/MusicListSaved";
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
        title: new Text('Friends'),
        leading: new Icon(Icons.people),
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
      new Divider(),
      new ListTile(
        title: new Text('Logout'),
        leading: new Icon(Icons.exit_to_app),
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
  ));
}

makeAppBar(String text, dynamic menuKey) {
  return AppBar(
    leading: new IconButton(
        icon: new Icon(Icons.menu),
        onPressed: () => menuKey.currentState.openDrawer()),
    title: Text(text),
  );
}
