import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/api/requestProfile.dart';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/widgets/AppBarDrawer.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/api/requestFriendList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

class FriendList extends StatefulWidget {
  final AudioPlayer _audioPlayer;
  final User _user;

  FriendList(this._audioPlayer, this._user);

  @override
  State<StatefulWidget> createState() =>
      new FriendListState(_audioPlayer, _user);
}

class FriendListState extends State<FriendList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  List<User> _data = [];
  final AudioPlayer _audioPlayer;
  final User _user;

  FriendListState(this._audioPlayer, this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppBarDrawer(_audioPlayer, _user),
      appBar: makeAppBar('Friends', _scaffoldKey),
      body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async => await _loadFriends(),
          child: ListView(
            children: _buildList(),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  _loadFriends() async {
    final friendList = await requestFriendList();
    if (friendList != null) {
      setState(() {
        _data = friendList;
      });
    } else {
      infoDialog(
          context, "Unable to get Friends List", "Something went wrong.");
    }
  }

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }
    return _data
        .map((User user) => new ListTile(
            title:
                new Text(user.last_name.isEmpty ? 'Unknown' : user.last_name),
            subtitle: new Text(
                user.first_name.isEmpty ? 'Unknown' : user.first_name,
                style: new TextStyle(color: Colors.black54)),
            onTap: () async {
              final friend = await requestProfileGet(friendId: user.id);
              await Navigator.of(context).pop();
//              await Navigator.of(context).push(MaterialPageRoute(
//                  builder: (BuildContext context) =>
//                      switchRoutes(_audioPlayer, route: 2, user: user, friend: friend)));
            },
            trailing: new IconButton(
                onPressed: () {},
                icon: new Icon(Icons.more_vert,
                    size: 35, color: Color.fromRGBO(100, 100, 100, 1))),
            leading: new CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                backgroundImage:
                    new Image.network(BASE_URL + user.image).image)))
        .toList();
  }
}
