import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';

class FriendList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendListState();
  }
}

class FriendListState extends State<FriendList> {
  final GlobalKey<ScaffoldState> menuKey = new GlobalKey<ScaffoldState>();
  List<User> _data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Friends', menuKey),
      backgroundColor: lightGrey,
    );
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute('/FriendList');
  }

  _loadSongs() async {}

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }
    return _data
        .map((User user) => ListTile(
            title: Text(user.first_name),
            subtitle:
                Text(user.last_name, style: TextStyle(color: Colors.black54)),
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new IconButton(
                    onPressed: () {
                      print('deleted');
                    },
                    icon: Icon(Icons.delete, size: 35),
                  ),
                )
              ],
            ),
            leading: Icon(
              Icons.face,
              size: 35,
            )))
        .toList();
  }
}
