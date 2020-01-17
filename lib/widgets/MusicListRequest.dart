import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';

class MusicListRequest extends StatefulWidget {
  final RmxAudioPlayer _audioPlayer;

  MusicListRequest(this._audioPlayer);

  @override
  State<StatefulWidget> createState() =>
      new MusicListRequestState(this._audioPlayer);
}

class MusicListRequestState extends State<MusicListRequest> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  final RmxAudioPlayer _audioPlayer;

  MusicListRequestState(this._audioPlayer);

  List<Song> _data = [];
  List<Song> _localData = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async => await _loadSongs(),
        child: ModalProgressHUD(
            child: ListView(
              children: _buildList(),
            ),
            inAsyncCall: _loading));
  }

  _setUpdatingStatus() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  _loadSongs() async {
    _setUpdatingStatus();
    final listSong = await requestMusicListGet();
    if (listSong != null) {
      setState(() {
        if (_data.isEmpty) {
          _data = listSong;
        }
      });
    } else {
      infoDialog(context, "Unable to get Music List", "Something went wrong.");
    }
    _setUpdatingStatus();
  }

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }

    return _data
        .map((Song song) => ListTile(
            title: Text(song.name),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new Text(formatTime(song.duration)),
                ),
                Container(
                  child: new IconButton(
                    onPressed: _localData.contains(song)
                        ? null
                        : () {
                            downloadSong(song, context: context);
                          },
                    icon: Icon(Icons.file_download,
                        size: 35, color: Color.fromRGBO(100, 100, 100, 1)),
                  ),
                )
              ],
            ),
            leading: IconButton(
                onPressed: () {
                  print('play started');
                  if (_audioPlayer.isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.setPlaylistItems([
                      new AudioTrack(
                          album: 'saved',
                          artist: song.artist,
                          assetUrl: song.download,
                          title: song.name,
                          trackId: song.song_id.toString())
                    ]);
                    _audioPlayer.play();
                  }
                  setState(() {
                    song.isPlaying = !song.isPlaying;
                  });
                },
                icon: Icon(
                  song.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
