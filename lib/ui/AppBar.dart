import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> menuKey = new GlobalKey<ScaffoldState>();


makeAppBar(String text) {
  return AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () => menuKey.currentState.openDrawer()),
        title: Text(text),
      );
}
