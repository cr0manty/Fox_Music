import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fox_music/functions/utils/set_playlist_song.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/widgets/playlist_dialog.dart';

showPickerDialog(BuildContext context, MusicData musicData, List<Playlist> playlist, int songId) async {
  final List<PlaylistCheckbox> listData = await Future.wait(playlist.map((playlist) async {
    return  PlaylistCheckbox(playlist, checked: playlist.inList(songId));
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
                          child:
                              DialogPlaylistContent(playlistList: listData))))),
        ),
      );
    },
  );
}
