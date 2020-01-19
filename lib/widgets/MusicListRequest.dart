import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/save/savePlayedSong.dart';
import 'package:vk_parse/functions/get/getPlayedSong.dart';

class MusicListRequest extends StatefulWidget {
  final AudioPlayer _audioPlayer;

  MusicListRequest(this._audioPlayer);

  @override
  State<StatefulWidget> createState() =>
      new MusicListRequestState(_audioPlayer);
}

class MusicListRequestState extends State<MusicListRequest> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  List<Song> _data = [];
  List<Song> _localData = [];
  Song playedSong;

  bool _loading = false;
  int nowPlayingSongId = -1;

  final AudioPlayer _audioPlayer;

  MusicListRequestState(this._audioPlayer);

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
    _setPlayedSong();
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

  _setPlayedSong() async {
    playedSong = await getPlayedSong();
  }

  List<Widget> _buildList() {
    if (_data == null) {
      return null;
    }

    return _data
        .map((Song song) => ListTile(
            title: Text(song.title),
            subtitle:
                Text(song.artist, style: TextStyle(color: Colors.black54)),
            onTap: () async {
              print('play started');
              if (_audioPlayer.state == AudioPlayerState.PLAYING) {
                await _audioPlayer.stop();
              }
              if (_audioPlayer.state == AudioPlayerState.PAUSED ||
                  _audioPlayer.state == AudioPlayerState.COMPLETED ||
                  _audioPlayer.state == AudioPlayerState.STOPPED ||
                  _audioPlayer.state == null) {
                await _audioPlayer.play(song.download);
                await savePlayedSong(song);
                setState(() {
                  playedSong = song;
                });
              }
            },
            trailing: new Row(mainAxisSize: MainAxisSize.min, children: [
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
            ]),
            leading: IconButton(
                onPressed: () async {
                  print('play started');
                  if (_audioPlayer.state == AudioPlayerState.PLAYING) {
                    await _audioPlayer.stop();
                  }
                  if (_audioPlayer.state == AudioPlayerState.PAUSED ||
                      _audioPlayer.state == AudioPlayerState.COMPLETED ||
                      _audioPlayer.state == AudioPlayerState.STOPPED ||
                      _audioPlayer.state == null) {
                    await _audioPlayer.play(song.path, isLocal: true);
                    await savePlayedSong(song);
                    setState(() {
                      playedSong = song;
                    });
                  }
                },
                icon: Icon(
                  _audioPlayer.state == AudioPlayerState.PLAYING &&
                          playedSong.song_id == song.song_id
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 35,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ))))
        .toList();
  }
}
