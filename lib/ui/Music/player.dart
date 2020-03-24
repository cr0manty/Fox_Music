import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fox_music/ui/Music/music_text.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/functions/utils/pick_dialog.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/utils/database.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/utils/swipe_detector.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  List<Playlist> _playlistList = [];
  Duration songPosition;
  Duration songDuration;
  int selectItem = 1;
  bool init = true;
  bool initCC = true;

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

  void seek(MusicData musicData, {duration}) {
    setState(() {
      int value = (duration != null && duration < 1
              ? durToInt(songDuration) * duration
              : 0)
          .toInt();
      musicData.audioPlayer.seek(Duration(seconds: value));
    });
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
    FocusScope.of(context).requestFocus(FocusNode());
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    double screenHeight = MediaQuery.of(context).size.height;
    MusicData musicData = Provider.of<MusicData>(context);

    if (init && mounted) {
      _durationSubscription =
          musicData.audioPlayer.onDurationChanged.listen((duration) {
        if (mounted)
          setState(() {
            songDuration = duration;
          });
        if (musicData.currentSong?.duration != duration.inSeconds &&
            musicData.currentSong?.path != null) {
          musicData.currentSong.duration = duration.inSeconds;
          musicData.renameSong(musicData.currentSong);
        }
        if (initCC) {
          musicData.setCCData(duration);
          initCC = false;
        }
      });
      _positionSubscription =
          musicData.audioPlayer.onAudioPositionChanged.listen((p) {
        if (mounted)
          setState(() {
            songPosition = p;
          });
      });
      musicData.audioPlayer.onPlayerError.listen((msg) {
        print('audioPlayer error : $msg');
        setState(() {
          musicData.currentSong = null;
          musicData.playerStop();
          songDuration = Duration(seconds: 0);
          songPosition = Duration(seconds: 0);
        });
        if (mounted) Navigator.of(context).pop();
      });
    }
    double sliderValue = durToInt(songPosition) / durToInt(songDuration);

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        child: Material(
            child: Column(
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
                            child: SwipeDetector(
                              onSwipeDown: () {
                                Navigator.pop(context);
                              },
                              onSwipeLeft: musicData.currentSong != null
                                  ? () {
                                      musicData.next();
                                    }
                                  : null,
                              onSwipeRight: musicData.currentSong != null
                                  ? () {
                                      if (sliderValue < 0.3 &&
                                          sliderValue > 0.05) {
                                        seek(musicData);
                                      } else {
                                        musicData.prev();
                                      }
                                    }
                                  : null,
                              onTap: _play(musicData),
                            ))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenHeight - pictureHeight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(50, 50, 50, 0.9)),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: <
                                  Widget>[
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: main_color.withOpacity(0.6),
                                inactiveTrackColor:
                                    Color.fromRGBO(100, 100, 100, 0.6),
                                trackHeight: 3.0,
                                thumbColor: main_color.withOpacity(0.6),
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 4.0),
                                overlayColor: Colors.red.withAlpha(12),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 17.0),
                              ),
                              child: Slider(
                                onChanged: (value) {},
                                onChangeEnd: (double value) {
                                  seek(musicData, duration: value);
                                },
                                value: songPosition != null &&
                                        sliderValue > 0.0 &&
                                        sliderValue < 1.0
                                    ? sliderValue
                                    : 0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      songPosition != null &&
                                              sliderValue > 0.0 &&
                                              sliderValue < 1.0
                                          ? timeFormat(songPosition)
                                          : '00:00',
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.7))),
                                  Text(
                                      songDuration != null
                                          ? timeFormat(songDuration)
                                          : '00:00',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)))
                                ],
                              ),
                            ),
                            Container(
                                height: screenHeight * 0.125,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                            musicData.currentSong != null
                                ? Container(
                                    child: Text(
                                      '${musicData.currentIndexPlaylist + 1} / ${musicData.playlist.length}',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  )
                                : Container(),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        onTap: musicData.repeatClick,
                                        child: Container(
                                          color: Colors.transparent,
                                          height: screenHeight * 0.07,
                                          width: screenHeight * 0.07,
                                          child: Icon(SFSymbols.repeat,
                                              size: screenHeight * 0.03,
                                              color: musicData.repeat
                                                  ? main_color
                                                  : Colors.grey),
                                        )),
                                    GestureDetector(
                                        onTap: musicData.currentSong != null
                                            ? () {
                                                if (sliderValue < 0.3 &&
                                                    sliderValue > 0.02) {
                                                  seek(musicData);
                                                } else {
                                                  musicData.prev();
                                                }
                                              }
                                            : null,
                                        child: Container(
                                            color: Colors.transparent,
                                            height: screenHeight * 0.07,
                                            width: screenHeight * 0.1,
                                            child: Icon(
                                              SFSymbols.backward_fill,
                                              color: Colors.grey,
                                              size: screenHeight * 0.045,
                                            ))),
                                    GestureDetector(
                                      onTap: _play(musicData),
                                      child: Container(
                                          color: Colors.transparent,
                                          height: screenHeight * 0.07,
                                          width: screenHeight * 0.1,
                                          child: Icon(
                                            musicData.playerState ==
                                                    AudioPlayerState.PLAYING
                                                ? SFSymbols.pause_fill
                                                : SFSymbols.play_fill,
                                            color: Colors.grey,
                                            size: screenHeight * 0.045,
                                          )),
                                    ),
                                    GestureDetector(
                                        onTap: musicData.currentSong != null
                                            ? () {
                                                musicData.next();
                                              }
                                            : null,
                                        child: Container(
                                            color: Colors.transparent,
                                            height: screenHeight * 0.07,
                                            width: screenHeight * 0.1,
                                            child: Icon(
                                              SFSymbols.forward_fill,
                                              color: Colors.grey,
                                              size: screenHeight * 0.045,
                                            ))),
                                    GestureDetector(
                                        onTap: musicData.mixClick,
                                        child: Container(
                                          color: Colors.transparent,
                                          height: screenHeight * 0.07,
                                          width: screenHeight * 0.07,
                                          child: Icon(SFSymbols.shuffle,
                                              size: screenHeight * 0.03,
                                              color: musicData.mix
                                                  ? main_color
                                                  : Colors.grey),
                                        ))
                                  ],
                                )),
                            Expanded(
                                child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                                onTap:
                                                    musicData.currentSong !=
                                                            null
                                                        ? () async {
                                                            var songLyrics =
                                                                await DBProvider
                                                                    .db
                                                                    .songLyrics(musicData
                                                                        .currentSong
                                                                        .song_id);
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .push(BottomRoute(
                                                                    page: MusicTextPage(
                                                                        songText: songLyrics.isEmpty
                                                                            ? ''
                                                                            : songLyrics[0].toString())));
                                                          }
                                                        : null,
                                                child: Container(
                                                    color: Colors.transparent,
                                                    padding: EdgeInsets.all(11),
                                                    width: screenHeight * 0.055,
                                                    height:
                                                        screenHeight * 0.055,
                                                    child: SvgPicture.asset(
                                                        'assets/svg/lyrics.svg',
                                                        color: Colors.grey))),
                                            Expanded(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    child: SliderTheme(
                                                      data: SliderTheme.of(
                                                              context)
                                                          .copyWith(
                                                        activeTrackColor: Colors
                                                            .white
                                                            .withOpacity(0.6),
                                                        inactiveTrackColor:
                                                            Color.fromRGBO(100,
                                                                100, 100, 0.6),
                                                        trackHeight: 3.0,
                                                        thumbColor: Colors.white
                                                            .withOpacity(0.6),
                                                        thumbShape:
                                                            RoundSliderThumbShape(
                                                                enabledThumbRadius:
                                                                    4.0),
                                                        overlayColor: Colors.red
                                                            .withAlpha(12),
                                                        overlayShape:
                                                            RoundSliderOverlayShape(
                                                                overlayRadius:
                                                                    17.0),
                                                      ),
                                                      child: Slider(
                                                        onChanged: (value) {},
                                                        onChangeEnd: musicData
                                                            .updateVolume,
                                                        value: musicData.volume !=
                                                                    null &&
                                                                musicData
                                                                        .volume >
                                                                    0.0 &&
                                                                musicData
                                                                        .volume <=
                                                                    1.0
                                                            ? musicData.volume
                                                            : 0,
                                                      ),
                                                    ))),
                                            GestureDetector(
                                                onTap: musicData.currentSong !=
                                                        null
                                                    ? () => showPickerDialog(
                                                        context,
                                                        musicData,
                                                        _playlistList,
                                                        musicData.currentSong
                                                            .song_id)
                                                    : null,
                                                child: Container(
                                                    color: Colors.transparent,
                                                    padding: EdgeInsets.all(11),
                                                    width: screenHeight * 0.056,
                                                    height:
                                                        screenHeight * 0.056,
                                                    child: SvgPicture.asset(
                                                        'assets/svg/add_to_playlist.svg',
                                                        color: Colors.grey))),
                                          ],
                                        ))))
                          ]),
                        ))
                  ],
                ))
          ],
        )));
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }
}
