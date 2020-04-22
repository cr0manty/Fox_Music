import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/api/friends_list.dart';
import 'package:fox_music/api/user_search.dart';
import 'package:fox_music/functions/format/image.dart';
import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Account/people.dart';
import 'package:fox_music/utils/apple_search.dart';

class SearchPeoplePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SearchPeoplePageState();
}

class SearchPeoplePageState extends State<SearchPeoplePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();

  Map<int, int> _friends = {};
  List<Relationship> _userList = [];

  _loadFriends() async {
    final friendList = await friendListIdGet();
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
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    AccountData accountData = Provider.of<AccountData>(context);

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(
          actionsForegroundColor: main_color,
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
              itemBuilder: (context, index) =>
                  _buildUserCard(accountData, downloadData, index),
            ))));
  }

  _buildUserCard(
      AccountData accountData, MusicDownloadData downloadData, int index) {
    int newIndex = index - 1;

    if (index == 0) {
      return AppleSearch(
        controller: controller,
        onChange: (value) async {
          List<User> userList = await userSearchGet(value);
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
                    Navigator.of(_scaffoldKey.currentContext).push(
                        CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                MultiProvider(providers: [
                                  ChangeNotifierProvider<AccountData>.value(
                                      value: accountData),
                                  ChangeNotifierProvider<
                                          MusicDownloadData>.value(
                                      value: downloadData),
                                ], child: PeoplePage(relationship))));
                  },
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          Image.network(formatImage(relationship.user.image))
                              .image))),
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
