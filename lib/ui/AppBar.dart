import 'package:flutter/material.dart';

import 'package:vk_parse/functions/logout.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/infoDialog.dart';


makeDrawer(context) {
  return new Drawer(
      child: new ListView(
    children: <Widget>[
      new DrawerHeader(
        child: new Text('Account'),
      ),
      new ListTile(
        title: new Text('Update music list'),
        leading: new Icon(Icons.update),
        onTap: () async {
          try {
            final listNewSong = await requestMusicListPost(context);
            showTextDialog(
                context, "New songs", "$listNewSong new songs found.", "OK");
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
            Navigator.pushNamed(context, newRouteName);
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
            Navigator.pushNamed(context, newRouteName);
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
            Navigator.pushNamed(context, newRouteName);
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
