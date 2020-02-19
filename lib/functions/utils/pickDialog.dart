import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vk_parse/functions/utils/setPlaylistSong.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:vk_parse/models/PlaylistCheckbox.dart';
import 'package:vk_parse/utils/DialogPlaylistContent.dart';

showPickerDialog(BuildContext context, List<Playlist> playlist, int songId) async {
  final List<PlaylistCheckbox> listData = await Future.wait(playlist.map((playlist) async {
    return  PlaylistCheckbox(playlist, checked: playlist.inList(songId));
  }));
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Add song to playlist'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              setPlaylistSong(listData, songId);
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
                          child:
                              DialogPlaylistContent(playlistList: listData))))),
        ),
      );
    },
  );
}
