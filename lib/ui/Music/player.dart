import 'dart:async';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fox_music/ui/Music/music_text.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/utils/help.dart';
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
  StreamSubscription _playerStream;
  List<Playlist> _playlistList = [];

  int selectItem = 1;
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
    _playerStream =
        MusicData.instance.playerStream.listen((event) => setState(() {}));
  }

  _play() {
    return MusicData.instance.currentSong != null
        ? () => AudioManager.instance.isPlaying
            ? MusicData.instance.playerPause()
            : MusicData.instance.playerResume()
        : null;
  }

  Future _songText() async {
    var songLyrics =
        await DBProvider.db.getSongText(MusicData.instance.currentSong.song_id);
    Navigator.of(context, rootNavigator: true).push(BottomRoute(
        page: MusicTextPage(
      songText: songLyrics.isEmpty ? '' : songLyrics[0]['text'].toString(),
      songId: MusicData.instance.currentSong.song_id,
    )));
  }

  Widget _bottomButtons(double screenHeight) {
    return Expanded(
        child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                        onTap: MusicData.instance.currentSong != null
                            ? () => _songText()
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
                                onChanged: MusicData.instance.updateVolume,
                                value: MusicData.instance.volume != null &&
                                        MusicData.instance.volume > 0.0 &&
                                        MusicData.instance.volume <= 1.0
                                    ? MusicData.instance.volume
                                    : 0,
                              ),
                            ))),
                    GestureDetector(
                        onTap: MusicData.instance.currentSong != null
                            ? () => HelpTools.showPickerDialog(
                                context,
                                MusicData.instance,
                                _playlistList,
                                MusicData.instance.currentSong.song_id)
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

  Widget _mainMusicControls(double screenHeight, double sliderValue) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: MusicData.instance.repeatClick,
                child: Container(
                  color: Colors.transparent,
                  height: screenHeight * 0.07,
                  width: screenHeight * 0.07,
                  child: Icon(SFSymbols.repeat,
                      size: screenHeight * 0.03,
                      color: MusicData.instance.repeat
                          ? HexColor.main()
                          : Colors.grey),
                )),
            GestureDetector(
                onTap: MusicData.instance.currentSong != null &&
                        MusicData.instance.playerState != PlayerState.BUFFERING
                    ? sliderValue < 0.3 && sliderValue > 0.02
                        ? MusicData.instance.seek
                        : MusicData.instance.prev
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
              onTap: _play(),
              child: Container(
                  color: Colors.transparent,
                  height: screenHeight * 0.07,
                  width: screenHeight * 0.1,
                  child: MusicData.instance.playerState == PlayerState.BUFFERING
                      ? CupertinoActivityIndicator()
                      : Icon(
                          MusicData.instance.playerState == PlayerState.PLAYING
                              ? SFSymbols.pause_fill
                              : SFSymbols.play_fill,
                          color: Colors.grey,
                          size: screenHeight * 0.045,
                        )),
            ),
            GestureDetector(
                onTap: MusicData.instance.currentSong != null &&
                        MusicData.instance.playerState != PlayerState.BUFFERING
                    ? MusicData.instance.next
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
                onTap: () => MusicData.instance.mixClick(),
                child: Container(
                  color: Colors.transparent,
                  height: screenHeight * 0.07,
                  width: screenHeight * 0.07,
                  child: Icon(SFSymbols.shuffle,
                      size: screenHeight * 0.03,
                      color: MusicData.instance.mix
                          ? HexColor.main()
                          : Colors.grey),
                ))
          ],
        ));
  }

  Widget _songDetails(double screenHeight) {
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

  double _sliderValue(double sliderValue) {
    double value = startSlide ? newSliderValue : sliderValue;
    return MusicData.instance.songPosition != null && value > 0.0 && value < 1.0
        ? value
        : 0;
  }

  Widget _slider(double sliderValue) {
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
          MusicData.instance.seek(duration: value);
        }),
        value: _sliderValue(sliderValue),
      ),
    );
  }

  Widget _songTimeLine(double sliderValue) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              MusicData.instance.songPosition != null &&
                      sliderValue > 0.0 &&
                      sliderValue < 1.0
                  ? HelpTools.timeFormat(MusicData.instance.songPosition)
                  : '00:00',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(
              MusicData.instance.songDuration != null
                  ? HelpTools.timeFormat(MusicData.instance.songDuration)
                  : '00:00',
              style: TextStyle(color: Colors.white.withOpacity(0.7)))
        ],
      ),
    );
  }

  Widget _mainControls(double pictureHeight, double sliderValue) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
            height: pictureHeight,
            width: MediaQuery.of(context).size.width,
            child: SwipeDetector(
              onSwipeDown: Navigator.of(context).pop,
              onSwipeLeft: MusicData.instance.currentSong != null
                  ? () {
                      MusicData.instance.next();
                    }
                  : null,
              onSwipeRight: MusicData.instance.currentSong != null
                  ? () {
                      if (sliderValue < 0.3 && sliderValue > 0.05) {
                        MusicData.instance.seek();
                      } else {
                        MusicData.instance.prev();
                      }
                    }
                  : null,
              onTap: _play(),
            )));
  }

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    double screenHeight = MediaQuery.of(context).size.height;

    double sliderValue = HelpTools.durToInt(MusicData.instance.songPosition) /
        HelpTools.durToInt(MusicData.instance.songDuration);

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
                    _mainControls(pictureHeight, sliderValue),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenHeight - pictureHeight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(50, 50, 50, 0.9)),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _slider(sliderValue),
                                _songTimeLine(sliderValue),
                                _songDetails(screenHeight),
                                MusicData.instance.currentSong != null
                                    ? Container(
                                        child: Text(
                                          '${MusicData.instance.selectedIndex + 1} / ${AudioManager.instance.audioList.length}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      )
                                    : Container(),
                                _mainMusicControls(screenHeight, sliderValue),
                                _bottomButtons(screenHeight)
                              ]),
                        ))
                  ],
                ))
          ],
        )));
  }

  @override
  void dispose() {
    super.dispose();
    _playerStream?.cancel();
  }
}
