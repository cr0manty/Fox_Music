import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/api/requestFriendList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

class FriendListPage extends StatefulWidget {
  List<User> _friendList = [];

  @override
  State<StatefulWidget> createState() => new FriendListPageState();
}

class FriendListPageState extends State<FriendListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: Text('Friends'), centerTitle: true),
      body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async => await _loadFriends(),
          child: ListView.builder(
            itemCount: widget._friendList.length,
            itemBuilder: (context, index) => _buildUserCard(index),
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
        widget._friendList = friendList;
      });
    } else {
      infoDialog(
          context, "Unable to get Friends List", "Something went wrong.");
    }
  }

  _buildUserCard(int index) {
    User user = widget._friendList[index];

    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
                title: Text(user.last_name.isEmpty ? 'Unknown' : user.last_name,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(
                    user.first_name.isEmpty ? 'Unknown' : user.first_name,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: null,
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        Image.network(BASE_URL + user.image).image))),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: null,
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
