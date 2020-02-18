import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:vk_parse/provider/AccountData.dart';
import 'package:vk_parse/provider/MusicData.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
import 'package:vk_parse/ui/Account/VKAuthPage.dart';

class VKMusicListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new VKMusicListPageState();
}

class VKMusicListPageState extends State<VKMusicListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  bool init = true;
  Song playedSong;

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text('Music'),
          centerTitle: true,
          actions: accountData.user != null && accountData.user.can_use_vk
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      try {
                        final listNewSong = await musicListPost();
                        if (listNewSong != null) {
                          infoDialog(_scaffoldKey.currentContext, "New songs",
                              "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
                        } else {
                          infoDialog(
                              _scaffoldKey.currentContext,
                              "Something went wrong",
                              "Unable to get Music List.");
                        }
                      } catch (e) {
                        print(e);
                      } finally {
                        downloadData.loadMusic();
                      }
                    },
                  )
                ]
              : [],
        ),
        body: _buildBody(accountData, downloadData));
  }

  _buildBody(AccountData accountData, MusicDownloadData downloadData) {
    return accountData.user != null &&
            (accountData.user.can_use_vk || accountData.user.is_staff)
        ? RefreshIndicator(
            key: _refreshKey,
            onRefresh: () => downloadData.loadMusic(),
            child: ListView.builder(
              itemCount: downloadData.dataSong.length,
              itemBuilder: (context, index) =>
                  _buildSongListTile(downloadData, index),
            ))
        : Center(
            child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.2),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Stack(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  child: Text(
                    'In order to listen, you have to allow access to your account details',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
              Center(
                  child: CupertinoButton(
                child: Text('Submit'),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.of(_scaffoldKey.currentContext).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<AccountData>.value(
                                  value: accountData,
                                  child: VKAuthPage(accountData))));
                },
              )),
            ]),
          ));
  }

  _downloadSong(MusicDownloadData downloadData, Song song) {
    downloadData.downloadSingle(song);
  }

  _buildSongListTile(MusicDownloadData downloadData, int index) {
    Song song = downloadData.dataSong[index];
    if (init) {
      downloadData.onResultChanged.listen((result) {
        downloadData.showInfo(_scaffoldKey.currentContext, result);
      });
      init = false;
    }

    return Stack(children: [
      Column(children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
              height: 72,
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () {
                  _downloadSong(downloadData, song);
                },
                trailing: Text(formatDuration(song.duration),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async {
                bool isDeleted = await hideMusic(song.song_id);
                if (isDeleted) {
                  setState(() {
                    downloadData.dataSong.removeAt(index);
                  });
                }
              },
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
      ]),
      downloadData.currentSong == song
          ? Container(
              height: 72,
              width: MediaQuery.of(context).size.width * downloadData.progress,
              decoration:
                  BoxDecoration(color: Colors.redAccent.withOpacity(0.2)),
            )
          : Container(),
    ]);
  }
}
