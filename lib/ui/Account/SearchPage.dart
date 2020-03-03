import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:vk_parse/api/friendList.dart';
import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/api/userSearch.dart';
import 'package:vk_parse/functions/format/formatImage.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/showShackbar.dart';
import 'package:vk_parse/models/Relationship.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/provider/AccountData.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
import 'package:vk_parse/ui/Account/PeoplePage.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchInput = new TextEditingController();
  Map<int, int> _friends = {};
  List<Relationship> _userList = [];
  List<Song> _songList = [];
  int _tabIndex = 0;

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
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return DefaultTabController(
        length: 2,
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
              middle: Text('Search'),
              previousPageTitle: 'Back',
            ),
            child: Material(
                color: Colors.transparent,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                          alignment: FractionalOffset.topCenter,
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                  controller: _searchInput,
                                  onChanged: (value) async {
                                    if (_tabIndex == 0) {
                                      List<Song> songList =
                                          await musicSearchGet(value);
                                      setState(() {
                                        _songList = songList;
                                      });
                                    } else {
                                      List<User> userList =
                                          await userSearchGet(value);
                                      _setFriendStatus(userList);
                                    }
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: "Search",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0))))))),
                      Divider(),
                      _buildTabView(accountData, downloadData)
                    ]))));
  }

  _buildTabView(AccountData accountData, MusicDownloadData downloadData) {
    return Flexible(
        child: TabBarView(children: <Widget>[
      ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: _songList.length,
        itemBuilder: (context, index) =>
            _buildSongListTile(downloadData, index),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: _userList.length,
        itemBuilder: (context, index) =>
            _buildUserCard(accountData, downloadData, index),
      )
    ]));
  }

  _buildSongListTile(MusicDownloadData downloadData, int index) {
    Song song = _songList[index];
    if (song == null) {
      return null;
    }
    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: new Container(
            child: ListTile(
          contentPadding: EdgeInsets.only(left: 30, right: 20),
          title: Text(song.title,
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
          subtitle: Text(song.artist,
              style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
          onTap: () {
            downloadData.query = song;
          },
          trailing: Text(formatDuration(song.duration),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: !song.in_my_list
            ? <Widget>[
                new IconSlideAction(
                  caption: 'Add',
                  color: Colors.blue,
                  icon: Icons.add,
                  onTap: () async {
                    bool isAdded = await addMusic(song.song_id);
                    if (isAdded == null) {
                      showSnackBar(context, 'Song alredy in your list');
                    } else if (isAdded) {
                      setState(() {
                        song.in_my_list = true;
                      });
                    }
                  },
                ),
              ]
            : [],
        secondaryActions: song.in_my_list
            ? <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    bool isDeleted = await hideMusic(song.song_id);
                    if (isDeleted) {
                      setState(() {
                        song.in_my_list = false;
                      });
                    }
                  },
                ),
              ]
            : [],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }

  _buildUserCard(
      AccountData accountData, MusicDownloadData downloadData, int index) {
    Relationship relationship = _userList[index];

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
            new IconSlideAction(
              caption: relationship.buttonName(),
              color: Colors.blue,
              icon: Icons.perm_identity,
              onTap: () => relationship.sendRequest(),
            ),
          ],
          secondaryActions: relationship.status != RelationshipStatus.BLOCK
              ? <Widget>[
                  new IconSlideAction(
                    caption: 'Block',
                    color: Colors.red,
                    icon: Icons.block,
                    onTap: () => relationship.sendBlock(),
                  ),
                ]
              : null),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
