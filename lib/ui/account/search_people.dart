import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/utils/api.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/ui/Account/people.dart';
import 'package:fox_music/widgets/apple_search.dart';

class SearchPeoplePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchPeoplePageState();
}

class SearchPeoplePageState extends State<SearchPeoplePage> {
  TextEditingController controller = TextEditingController();

  Map<int, int> _friends = {};
  List<Relationship> _userList = [];

  _loadFriends() async {
    final friendList = await Api.friendListIdGet();
    setState(() {
      _friends = friendList;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  _setFriendStatus(List<User> userList) {
    List<Relationship> newUserList = [];

    userList.forEach((User user) {
      newUserList.add(Relationship(user, statusId: _friends[user.id] ?? -1));
    });

    setState(() {
      _userList = newUserList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          actionsForegroundColor: HexColor.main(),
          middle: Text('People Search'),
          previousPageTitle: 'Back',
        ),
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
                child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _userList.isEmpty ? 2 : _userList.length + 1,
              itemBuilder: (context, index) => _buildUserCard(index),
            ))));
  }

  _buildUserCard(int index) {
    int newIndex = index - 1;

    if (index == 0) {
      return AppleSearch(
        controller: controller,
        onChange: (value) async {
          List<User> userList = await Api.userSearchGet(value);
          _setFriendStatus(userList);
        },
      );
    } else if (index == 1 && _userList.isEmpty) {
      return Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            'Your search returned no results.',
            style: TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ));
    }

    Relationship relationship = _userList[newIndex];

    return Column(children: [
      Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
              child: ListTile(
                  title: Text(
                      relationship.user.last_name.isEmpty
                          ? 'Unknown'
                          : relationship.user.last_name,
                      style:
                          TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                  subtitle: Text(
                      relationship.user.first_name.isEmpty
                          ? 'Unknown'
                          : relationship.user.first_name,
                      style:
                          TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            PeoplePage(relationship)));
                  },
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          Image.network(relationship.user.imageUrl()).image))),
          actions: <Widget>[
            IconSlideAction(
              caption: relationship.buttonName(),
              color: HexColor('#3a4e93'),
              icon: SFSymbols.person,
              onTap: () => relationship.sendRequest(),
            ),
          ],
          secondaryActions: relationship.status != RelationshipStatus.BLOCK
              ? <Widget>[
                  IconSlideAction(
                    caption: 'Block',
                    color: HexColor('#e22368'),
                    icon: Icons.block,
                    onTap: () => relationship.sendBlock(),
                  ),
                ]
              : null),
      Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Divider(
            height: 1,
            color: Colors.grey,
          ))
    ]);
  }
}
