import 'package:flutter/material.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:audioplayers/audioplayers.dart';

class Player extends StatefulWidget {
  final AudioPlayer _audioPlayer;
  final Song currentSong;

  Player(this._audioPlayer, {this.currentSong});

  @override
  State<StatefulWidget> createState() =>
      new PlayerState(_audioPlayer, currentSong);
}

class PlayerState extends State<Player> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  final AudioPlayer _audioPlayer;
  Song currentSong;
  AudioPlayerState _songState = AudioPlayerState.STOPPED;

  PlayerState(this._audioPlayer, this.currentSong) {
    if (currentSong == null) {
      currentSong = new Song();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      backgroundColor: Color.fromRGBO(35, 35, 35, 1),
      body: _buildPlayer(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  _buildPlayer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: FittedBox(
              child: Image.asset('assets/images/user-default.jpg'),
              fit: BoxFit.fill),
        ),
        Container(),
        Container(
            margin: const EdgeInsets.all(20.0),
            height: MediaQuery.of(context).size.height * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentSong.title != null ? currentSong.title : '',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  currentSong.artist != null ? currentSong.artist : '',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )
              ],
            )),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: currentSong != null ? null : null,
                  icon:
                      Icon(Icons.skip_previous, color: currentSong != null ? Color.fromRGBO(60, 60, 60, 1): Colors.grey,
                  size: 50,
                )),
              IconButton(
                onPressed: currentSong != null ? null : null,
                icon: Icon(
                  _songState == AudioPlayerState.PLAYING ? Icons.pause : Icons.play_arrow,
                  color: currentSong != null ? Color.fromRGBO(60, 60, 60, 1): Colors.grey,
                  size: 50,
                ),
              ),
              IconButton(
                  onPressed: currentSong != null ? null : null,
                  icon: Icon(
                    Icons.skip_next,
                    color: currentSong != null ? Color.fromRGBO(60, 60, 60, 1): Colors.grey,
                  size: 50,
                ),)
            ],
          ),
        )
      ],
    );
  }
}
