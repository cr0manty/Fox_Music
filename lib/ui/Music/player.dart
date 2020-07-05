import 'dart:async';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/ui/Music/music_text.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/instances/database.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/widgets/swipe_detector.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  List<Playlist> _playlistList = [];

  int selectItem = 1;
  bool init = true;
  bool initCC = true;
  bool startSlide = false;
  double newSliderValue = 0.0;

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
            if (AudioManager.instance.isPlaying) {
              await musicData.playerPause();
            } else {
              musicData.playerResume();
            }
          }
        : null;
  }

  Future _songText(MusicData musicData) async {
    var songLyrics =
        await DBProvider.db.getSongText(musicData.currentSong.song_id);
    Navigator.of(context, rootNavigator: true).push(BottomRoute(
        page: MusicTextPage(
      songText: songLyrics.isEmpty ? '' : songLyrics[0]['text'].toString(),
      songId: musicData.currentSong.song_id,
    )));
  }

  Widget _bottomButtons(MusicData musicData, double screenHeight) {
    return Expanded(
        child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                        onTap: musicData.currentSong != null
                            ? () => _songText(musicData)
                            : null,
                        child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.all(11),
                            width: screenHeight * 0.055,
                            height: screenHeight * 0.055,
                            child: SvgPicture.asset('assets/svg/lyrics.svg',
                                color: Colors.grey))),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white.withOpacity(0.6),
                                inactiveTrackColor:
                                    Color.fromRGBO(100, 100, 100, 0.6),
                                trackHeight: 3.0,
                                thumbColor: Colors.white.withOpacity(0.6),
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 4.0),
                                overlayColor: Colors.transparent,
                              ),
                              child: Slider(
                                onChanged: musicData.updateVolume,
                                value: musicData.volume != null &&
                                        musicData.volume > 0.0 &&
                                        musicData.volume <= 1.0
                                    ? musicData.volume
                                    : 0,
                              ),
                            ))),
                    GestureDetector(
                        onTap: musicData.currentSong != null
                            ? () => Utils.showPickerDialog(context, musicData,
                                _playlistList, musicData.currentSong.song_id)
                            : null,
                        child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.all(11),
                            width: screenHeight * 0.056,
                            height: screenHeight * 0.056,
                            child: SvgPicture.asset(
                                'assets/svg/add_to_playlist.svg',
                                color: Colors.grey))),
                  ],
                ))));
  }

  Widget _mainMusicControls(
      MusicData musicData, double screenHeight, double sliderValue) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: musicData.repeatClick,
                child: Container(
                  color: Colors.transparent,
                  height: screenHeight * 0.07,
                  width: screenHeight * 0.07,
                  child: Icon(SFSymbols.repeat,
                      size: screenHeight * 0.03,
                      color: musicData.repeat ? HexColor.main() : Colors.grey),
                )),
            GestureDetector(
                onTap: musicData.currentSong != null &&
                        musicData.playerState != PlayerState.BUFFERING
                    ? sliderValue < 0.3 && sliderValue > 0.02
                        ? musicData.seek
                        : musicData.prev
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
                  child: musicData.playerState == PlayerState.BUFFERING
                      ? CupertinoActivityIndicator()
                      : Icon(
                          musicData.playerState == PlayerState.PLAYING
                              ? SFSymbols.pause_fill
                              : SFSymbols.play_fill,
                          color: Colors.grey,
                          size: screenHeight * 0.045,
                        )),
            ),
            GestureDetector(
                onTap: musicData.currentSong != null &&
                        musicData.playerState != PlayerState.BUFFERING
                    ? musicData.next
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
                onTap: () => musicData.mixClick(),
                child: Container(
                  color: Colors.transparent,
                  height: screenHeight * 0.07,
                  width: screenHeight * 0.07,
                  child: Icon(SFSymbols.shuffle,
                      size: screenHeight * 0.03,
                      color: musicData.mix ? HexColor.main() : Colors.grey),
                ))
          ],
        ));
  }

  Widget _songDetails(MusicData musicData, double screenHeight) {
    return Container(
        height: screenHeight * 0.125,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AudioManager.instance.info?.title != null
                  ? AudioManager.instance.info.title
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: screenHeight * 0.03,
                  color: Color.fromRGBO(200, 200, 200, 1)),
            ),
            Text(
              AudioManager.instance.info?.desc != null
                  ? AudioManager.instance.info.desc
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  color: Color.fromRGBO(150, 150, 150, 1)),
            )
          ],
        ));
  }

  double _sliderValue(MusicData musicData, double sliderValue) {
    double value = startSlide ? newSliderValue : sliderValue;
    return musicData.songPosition != null && value > 0.0 && value < 1.0
        ? value
        : 0;
  }

  Widget _slider(MusicData musicData, double sliderValue) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: HexColor.main().withOpacity(0.6),
        inactiveTrackColor: Color.fromRGBO(100, 100, 100, 0.6),
        trackHeight: 3.0,
        thumbColor: HexColor.main().withOpacity(0.6),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
        overlayColor: Colors.transparent,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 17.0),
      ),
      child: Slider(
        onChanged: (value) => setState(() {
          newSliderValue = value;
        }),
        onChangeStart: (value) => setState(() {
          startSlide = true;
          newSliderValue = value;
        }),
        onChangeEnd: (value) => setState(() {
          startSlide = false;
          newSliderValue = value;
          musicData.seek(duration: value);
        }),
        value: _sliderValue(musicData, sliderValue),
      ),
    );
  }

  Widget _songTimeLine(MusicData musicData, double sliderValue) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              musicData.songPosition != null &&
                      sliderValue > 0.0 &&
                      sliderValue < 1.0
                  ? Utils.timeFormat(musicData.songPosition)
                  : '00:00',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(
              musicData.songDuration != null
                  ? Utils.timeFormat(musicData.songDuration)
                  : '00:00',
              style: TextStyle(color: Colors.white.withOpacity(0.7)))
        ],
      ),
    );
  }

  Widget _mainControls(
      MusicData musicData, double pictureHeight, double sliderValue) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
            height: pictureHeight,
            width: MediaQuery.of(context).size.width,
            child: SwipeDetector(
              onSwipeDown: Navigator.of(context).pop,
              onSwipeLeft: musicData.currentSong != null
                  ? () {
                      musicData.next();
                    }
                  : null,
              onSwipeRight: musicData.currentSong != null
                  ? () {
                      if (sliderValue < 0.3 && sliderValue > 0.05) {
                        musicData.seek();
                      } else {
                        musicData.prev();
                      }
                    }
                  : null,
              onTap: _play(musicData),
            )));
  }

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    double screenHeight = MediaQuery.of(context).size.height;
    MusicData musicData = Provider.of<MusicData>(context);

    double sliderValue = Utils.durToInt(musicData.songPosition) /
        Utils.durToInt(musicData.songDuration);

    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
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
                    _mainControls(musicData, pictureHeight, sliderValue),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenHeight - pictureHeight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(50, 50, 50, 0.9)),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _slider(musicData, sliderValue),
                                _songTimeLine(musicData, sliderValue),
                                _songDetails(musicData, screenHeight),
                                musicData.currentSong != null
                                    ? Container(
                                        child: Text(
                                          '${musicData.selectedIndex + 1} / ${AudioManager.instance.audioList.length}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      )
                                    : Container(),
                                _mainMusicControls(
                                    musicData, screenHeight, sliderValue),
                                _bottomButtons(musicData, screenHeight)
                              ]),
                        ))
                  ],
                ))
          ],
        )));
  }
}
