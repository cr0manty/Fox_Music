import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/functions/utils/pick_dialog.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/models/song.dart';
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
            if (musicData.playerState == PlayerState.PLAYING) {
              await musicData.playerPause();
            } else {
              musicData.playerResume();
            }
          }
        : null;
  }

  void _getSongText(Song song) {}

  String _getSecondsString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String _getMinuteString(int flooredValue) {
    return '${flooredValue % 60}'.padLeft(2, '0');
  }

  String _getTimeStringFromDouble(double value) {
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = _getMinuteString(flooredValue);
    String minuteString = _getSecondsString(decimalValue);

    return '$hourValue:$minuteString';
  }

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    double screenHeight = MediaQuery.of(context).size.height;
    MusicData musicData = Provider.of<MusicData>(context);
    double sliderValue = musicData.sliderValue()
        ? (musicData.songPosition / musicData.songDuration)
        : 0;
    FocusScope.of(context).requestFocus(FocusNode());

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
                                        musicData.seek();
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
                                activeTrackColor:
                                    Colors.redAccent.withOpacity(0.6),
                                inactiveTrackColor:
                                    Color.fromRGBO(100, 100, 100, 0.6),
                                trackHeight: 3.0,
                                thumbColor: Colors.redAccent.withOpacity(0.6),
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
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      musicData.songPosition != null &&
                                              sliderValue > 0.0 &&
                                              sliderValue < 1.0
                                          ? timeFormat(
                                              musicData.songPosition)
                                          : '00:00',
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.7))),
                                  Text(
                                      musicData.songDuration != null
                                          ? timeFormat(
                                              musicData.songDuration)
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
                            Divider(
                                color: Colors.transparent,
                                height: screenHeight * 0.03),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: musicData.repeatClick,
                                      child: Icon(SFSymbols.repeat,
                                          size: screenHeight * 0.025,
                                          color: musicData.repeat
                                              ? Colors.redAccent
                                              : Colors.grey),
                                    ),
                                    GestureDetector(
                                        onTap: musicData.currentSong != null
                                            ? () {
                                                if (sliderValue < 0.3 &&
                                                    sliderValue > 0.02) {
                                                  musicData.seek();
                                                } else {
                                                  musicData.prev();
                                                }
                                              }
                                            : null,
                                        child: Icon(
                                          SFSymbols.backward_fill,
                                          color: Colors.grey,
                                          size: screenHeight * 0.045,
                                        )),
                                    GestureDetector(
                                      onTap: _play(musicData),
                                      child: Icon(
                                        musicData.playerState ==
                                                PlayerState.PLAYING
                                            ? SFSymbols.pause_fill
                                            : SFSymbols.play_fill,
                                        color: Colors.grey,
                                        size: screenHeight * 0.045,
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: musicData.currentSong != null
                                            ? () {
                                                musicData.next();
                                              }
                                            : null,
                                        child: Icon(
                                          SFSymbols.forward_fill,
                                          color: Colors.grey,
                                          size: screenHeight * 0.045,
                                        )),
                                    GestureDetector(
                                      onTap: musicData.mixClick,
                                      child: Icon(SFSymbols.shuffle,
                                          size: screenHeight * 0.025,
                                          color: musicData.mix
                                              ? Colors.redAccent
                                              : Colors.grey),
                                    )
                                  ],
                                )),
                            Expanded(
                                child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap:
                                                  musicData.currentSong != null
                                                      ? () => _getSongText(
                                                          musicData.currentSong)
                                                      : null,
                                              child: Icon(
                                                  SFSymbols.text_justify,
                                                  size: screenHeight * 0.025,
                                                  color: Colors.grey),
                                            ),
                                            SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                activeTrackColor: Colors.white
                                                    .withOpacity(0.6),
                                                inactiveTrackColor:
                                                    Color.fromRGBO(
                                                        100, 100, 100, 0.6),
                                                trackHeight: 3.0,
                                                thumbColor: Colors.white
                                                    .withOpacity(0.6),
                                                thumbShape:
                                                    RoundSliderThumbShape(
                                                        enabledThumbRadius:
                                                            4.0),
                                                overlayColor:
                                                    Colors.red.withAlpha(12),
                                                overlayShape:
                                                    RoundSliderOverlayShape(
                                                        overlayRadius: 17.0),
                                              ),
                                              child: Slider(
                                                onChanged: (value) {},
                                                onChangeEnd:
                                                    musicData.updateVolume,
                                                value: musicData.volumeValue != null &&
                                                        musicData.volumeValue >
                                                            0.0 &&
                                                        musicData.volumeValue <=
                                                            1.0
                                                    ? musicData.volumeValue
                                                    : 0,
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: musicData.currentSong !=
                                                        null
                                                    ? () => showPickerDialog(
                                                        context,
                                                        _playlistList,
                                                        musicData.currentSong
                                                            .song_id)
                                                    : null,
                                                child: SvgPicture.asset(
                                                    'assets/svg/add_to_playlist.svg',
                                                    color: Colors.grey,
                                                    height: screenHeight * 0.02,
                                                    width:
                                                        screenHeight * 0.018)),
                                          ],
                                        ))))
                          ]),
                        ))
                  ],
                ))
          ],
        )));
  }
}
