import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:vk_parse/functions/format/formatImage.dart';
import 'package:vk_parse/models/Relationship.dart';
import 'package:vk_parse/provider/AccountData.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
import 'package:vk_parse/ui/Account/PeoplePage.dart';

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FriendListPageState();
}

class FriendListPageState extends State<FriendListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return CupertinoPageScaffold(
      key: _scaffoldKey,
      navigationBar: CupertinoNavigationBar(middle: Text('Friends')),
      child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () => accountData.loadFiendList(),
          child: ListView.builder(
            itemCount: accountData.friendList.length,
            itemBuilder: (context, index) =>
                _buildUserCard(accountData, downloadData, index),
          )),
    );
  }

  _buildUserCard(
      AccountData accountData, MusicDownloadData downloadData, int index) {
    Relationship relationship = accountData.friendList[index];

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
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(
                    relationship.user.first_name.isEmpty
                        ? 'Unknown'
                        : relationship.user.first_name,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () {
                  Navigator.of(_scaffoldKey.currentContext)
                      .push(CupertinoPageRoute(
                          builder: (context) => MultiProvider(providers: [
                                ChangeNotifierProvider<MusicDownloadData>.value(
                                    value: downloadData),
                                ChangeNotifierProvider<AccountData>.value(
                                    value: accountData),
                              ], child: PeoplePage(relationship))));
                },
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        Image.network(formatImage(relationship.user.image))
                            .image))),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Block',
            color: Colors.indigo,
            icon: Icons.block,
            onTap: null,
          ),
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
