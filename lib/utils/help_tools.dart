import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/utils/api.dart';
import 'package:fox_music/instances/database.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/widgets/playlist_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class HelpTools {
  static int durToInt(Duration time) {
    if (time != null) return time.inSeconds;
    return 0;
  }

  static String timeFormat(Duration time) {
    return [time.inMinutes, time.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  static String timeFormatDouble(double value) {
    Duration time = Duration(seconds: value.round());
    return [time.inMinutes, time.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  static Future downloadAll() async {
    // TODO
    try {
      List<Song> songList = await Api.musicListGet();
      int downloadAmount = 0;
      await songList.forEach((Song song) async {
        try {
          downloadAmount++;
        } catch (e) {
          print(e);
        }
      });
      return downloadAmount;
    } catch (e) {
      print(e);
      return -1;
    }
  }

  static Future infoDialog(BuildContext context, String title, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop(context);
                      })
                ]));
  }

  static Future pickDialog(BuildContext context, String title, String message,
      String url) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Open"),
                      onPressed: () async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ]));
  }

  static void showPickerDialog(BuildContext context, MusicData musicData,
      List<Playlist> playlist, int songId) async {
    final List<PlaylistCheckbox> listData =
    await Future.wait(playlist.map((playlist) async {
      return PlaylistCheckbox(playlist, checked: playlist.inList(songId));
    }));
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Add song to playlist'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () async {
                await setPlaylistSong(listData, songId);
                musicData.playlistPageUpdate = true;
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
          content: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
                child: Material(
                    color: Colors.transparent,
                    child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: Container(
                            height: 250,
                            child: DialogPlaylistContent(
                                playlistList: listData))))),
          ),
        );
      },
    );
  }

  static void setPlaylistSong(List<PlaylistCheckbox> list, int songId) async {
    await Future.wait(list.map((playlistChecked) async {
      if (playlistChecked.checked)
        await playlistChecked.playlist.addSong(songId);
      else
        await playlistChecked.playlist.deleteSong(songId);
      await DBProvider.db.updatePlaylist(playlistChecked.playlist);
    }));
  }

  static Future<List> getLocalSongs() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return Directory("$dir/songs/").listSync();
  }


}
