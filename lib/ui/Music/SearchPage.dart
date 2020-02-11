import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vk_parse/api/musicSearch.dart';
import 'package:vk_parse/api/userSearch.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/utils/urls.dart';

enum SearchType { MUSIC, PEOPLE }

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchInput = new TextEditingController();
  SearchType _searchType = SearchType.MUSIC;
  List<User> _userList = [];
  List<Song> _songList = [];

  @override
  Widget build(BuildContext context) {
    int itemAmount =
        _searchType == SearchType.MUSIC ? _songList.length : _userList.length;
    var builder =
        _searchType == SearchType.MUSIC ? _buildSongListTile : _buildUserCard;

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_searchType == SearchType.MUSIC
              ? 'Search music'
              : 'Search people'),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (SearchType result) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _searchType = result;
                    _searchInput.text = '';
                  });
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SearchType>>[
                      const PopupMenuItem<SearchType>(
                        value: SearchType.MUSIC,
                        child: Text('Search music'),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.PEOPLE,
                        child: Text('Search People'),
                      ),
                    ])
          ],
        ),
        body: Container(
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
                            if (_searchType == SearchType.MUSIC) {
                              List<Song> songList = await musicSearchGet(value);
                              setState(() {
                                _songList = songList;
                              });
                            } else {
                              List<User> userList = await userSearchGet(value);
                              setState(() {
                                _userList = userList;
                              });
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
              Flexible(
                  child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: itemAmount,
                itemBuilder: (context, index) => builder(index),
              ))
            ])));
  }

  @override
  void initState() {
    super.initState();
  }

  _buildSongListTile(int index) {
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
          onTap: () {},
          trailing: Text(formatDuration(song.duration),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Download',
            color: Colors.blue,
            icon: Icons.file_download,
            onTap: () {
              downloadSong(song, context: context);
            },
          ),
        ],
        secondaryActions: <Widget>[],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }

  _buildUserCard(int index) {
    User user = _userList[index];

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
                    backgroundImage: Image.network(user.image).image))),
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Add to friend',
            color: Colors.blue,
            icon: Icons.file_download,
            onTap: () {},
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
