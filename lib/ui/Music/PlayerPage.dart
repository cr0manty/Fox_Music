import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/pickDialog.dart';
import 'package:vk_parse/models/Playlist.dart';
import 'package:vk_parse/provider/MusicData.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/utils/Database.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Playlist> _playlistList = [];
  int selectItem = 1;

  _loadPlaylist() async {
    List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();
    if (mounted) {
      setState(() {
        _playlistList = playlistList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  _play(MusicData musicData) {
    return musicData.currentSong != null
        ? () async {
            if (musicData.playerState == AudioPlayerState.PLAYING) {
              await musicData.playerPause();
            } else {
              musicData.playerResume();
            }
          }
        : null;
  }

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.52;
    double screenHeight = MediaQuery.of(context).size.height - 80;
    MusicData musicData = Provider.of<MusicData>(context);
    double sliderValue =
        durToInt(musicData.songPosition) / durToInt(musicData.songDuration);
    FocusScope.of(context).requestFocus(FocusNode());

    return Scaffold(
        key: _scaffoldKey,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                height: screenHeight,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  Image.asset('assets/images/audio-cover.png')
                                      .image,
                              fit: BoxFit.cover)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Colors.grey.withOpacity(0.2),
                        Colors.red.withOpacity(0.2),
                      ], stops: [
                        0.4,
                        2
                      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            height: pictureHeight,
                            width: MediaQuery.of(context).size.width,
                            child: GestureDetector(
                              onTap: _play(musicData),
                            ))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenHeight - pictureHeight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(50, 50, 50, 0.9)),
                          child: Column(children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor:
                                        Colors.redAccent.withOpacity(0.6),
                                    inactiveTrackColor:
                                        Color.fromRGBO(100, 100, 100, 0.6),
                                    trackHeight: 2.0,
                                    thumbColor:
                                        Colors.redAccent.withOpacity(0.6),
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 4.0),
                                    overlayColor: Colors.red.withAlpha(12),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 17.0),
                                  ),
                                  child: Slider(
                                    onChanged: (value) {},
                                    onChangeEnd: (double value) {
                                      musicData.seek(duration: value);
                                    },
                                    value: musicData.songPosition != null &&
                                            sliderValue > 0.0 &&
                                            sliderValue < 1.0
                                        ? sliderValue
                                        : 0,
                                  ),
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      musicData.songPosition != null &&
                                              sliderValue > 0.0 &&
                                              sliderValue < 1.0
                                          ? timeFormat(musicData.songPosition)
                                          : '00:00',
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.7))),
                                  Text(
                                      musicData.songDuration != null
                                          ? timeFormat(musicData.songDuration)
                                          : '00:00',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)))
                                ],
                              ),
                            ),
                            musicData.currentSong != null
                                ? Container(
                                    child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Text(
                                      '${musicData.currentIndexPlaylist + 1} / ${musicData.playlist.length}',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ))
                                : Container(),
                            Container(
                                height: screenHeight * 0.1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      musicData.currentSong != null
                                          ? musicData.currentSong.title
                                          : '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.03,
                                          color:
                                              Color.fromRGBO(200, 200, 200, 1)),
                                    ),
                                    Text(
                                      musicData.currentSong != null
                                          ? musicData.currentSong.artist
                                          : '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.025,
                                          color:
                                              Color.fromRGBO(150, 150, 150, 1)),
                                    )
                                  ],
                                )),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        onPressed: musicData.currentSong != null
                                            ? () {
                                                if (sliderValue < 0.3 &&
                                                    sliderValue > 0.05) {
                                                  musicData.seek();
                                                } else {
                                                  musicData.prev();
                                                }
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: Colors.grey,
                                          size: screenHeight * 0.07,
                                        )),
                                    IconButton(
                                      onPressed: _play(musicData),
                                      icon: Icon(
                                        musicData.playerState ==
                                                AudioPlayerState.PLAYING
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.grey,
                                        size: screenHeight * 0.07,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: musicData.currentSong != null
                                            ? () {
                                                musicData.next();
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.skip_next,
                                          color: Colors.grey,
                                          size: screenHeight * 0.07,
                                        )),
                                  ],
                                )),
                            Expanded(
                                child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: musicData.repeatClick,
                                              icon: Icon(Icons.repeat,
                                                  size: screenHeight * 0.03,
                                                  color: musicData.repeat
                                                      ? Colors.redAccent
                                                      : Colors.grey),
                                            ),
                                            IconButton(
                                              onPressed:
                                                  musicData.currentSong != null
                                                      ? () => showPickerDialog(
                                                          context,
                                                          _playlistList,
                                                          musicData.currentSong
                                                              .song_id)
                                                      : null,
                                              icon: Icon(Icons.playlist_add,
                                                  size: screenHeight * 0.03,
                                                  color: Colors.grey),
                                            ),
                                            IconButton(
                                              onPressed: musicData.mixClick,
                                              icon: Icon(Icons.shuffle,
                                                  size: screenHeight * 0.03,
                                                  color: musicData.mix
                                                      ? Colors.redAccent
                                                      : Colors.grey),
                                            )
                                          ],
                                        ))))
                          ]),
                        ))
                  ],
                ))
          ],
        ));
  }
}
