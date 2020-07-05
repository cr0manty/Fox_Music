import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fox_music/instances/api.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/instances/download_data.dart';

class PeoplePage extends StatefulWidget {
  final Relationship relationship;

  PeoplePage(this.relationship);

  @override
  State<StatefulWidget> createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  List<Song> _friendSongList = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Search'),
          actionsForegroundColor: HexColor.main(),
          previousPageTitle: 'Back',
          trailing: widget.relationship.status != RelationshipStatus.BLOCK
              ? GestureDetector(
                  child: Icon(Icons.block),
                  onTap: () {},
                )
              : Container(),
        ),
        child: widget.relationship.status != RelationshipStatus.BLOCK
            ? SafeArea(child: _buildPage())
            : Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.block,
                                color: Colors.grey,
                                size:
                                    MediaQuery.of(context).size.height * 0.35),
                            Text(
                              'User has blocked you',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 25),
                              textAlign: TextAlign.center,
                            )
                          ])),
                )));
  }

  _buildPage() {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: CircleAvatar(
                    radius: MediaQuery.of(context).size.height * 0.13,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        Image.network(widget.relationship.user.imageUrl())
                            .image)),
            Text(
                widget.relationship.user.last_name.isEmpty &&
                        widget.relationship.user.first_name.isEmpty
                    ? 'Unknown'
                    : '${widget.relationship.user.first_name} ${widget.relationship.user.last_name}',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  color: widget.relationship.status == RelationshipStatus.FRIEND
                      ? HexColor.main()
                      : Colors.indigo,
                  onPressed: () {},
                  child: Text(
                    widget.relationship.buttonName(),
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Divider(),
            Flexible(
                child: widget.relationship.status == RelationshipStatus.FRIEND
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: _friendSongList.length,
                        itemBuilder: (context, index) => _buildSong(index),
                      )
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Only friends can view the list of tracks',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                          textAlign: TextAlign.center,
                        )))
          ],
        ));
  }

  _buildSong(int index) {
    Song song = _friendSongList[index];
    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
          contentPadding: EdgeInsets.only(left: 30, right: 20),
          title: Text(song.title,
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
          subtitle: Text(song.artist,
              style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
          onTap: () {
            MusicDownloadData.instance.query = song;
          },
          trailing: Text(song.formatDuration(),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: song.in_my_list == 0
            ? <Widget>[
                SlideAction(
                    color: Colors.blue,
                    child: Icon(
                      SFSymbols.plus,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      bool isAdded = await Api.addMusic(song.song_id);
                      if (isAdded) {
                        setState(() {
                          song.in_my_list = 1;
                        });
                      }
                    }),
              ]
            : [],
        secondaryActions: song.in_my_list == 1
            ? <Widget>[
                SlideAction(
                  color: HexColor('#d62d2d'),
                  child: Icon(
                    SFSymbols.trash,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    bool isDeleted = await Api.hideMusic(song.song_id);
                    if (isDeleted) {
                      setState(() {
                        song.in_my_list = 0;
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
}
