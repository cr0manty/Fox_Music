import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:vk_parse/widgets/BottomPicker.dart';

class Player extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PlayerState();
}



class PlayerState extends State<Player> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> list = [
    Text('asd'), Text('ads')
  ];
  int selectItem = 1;

  _addToPlaylistShowDialog() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return BottomPicker(
              child: CupertinoPicker(
              children: list,
              itemExtent: 25,
              onSelectedItemChanged: (int index) {
                selectItem = index;
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    double screenHeight = MediaQuery.of(context).size.height - 46.1;
    ProjectData _data = Provider.of<ProjectData>(context);
    double sliderValue =
        durToInt(_data.songPosition) / durToInt(_data.songDuration);
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
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenHeight - pictureHeight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(35, 35, 35, 0.9)),
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
                                      _data.seek(duration: value);
                                    },
                                    value: _data.songPosition != null &&
                                            sliderValue > 0.0 &&
                                            sliderValue < 1.0
                                        ? sliderValue
                                        : 0,
                                  ),
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      _data.songPosition != null &&
                                              sliderValue > 0.0 &&
                                              sliderValue < 1.0
                                          ? timeFormat(_data.songPosition)
                                          : '0:00',
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.7))),
                                  Text(
                                      _data.songDuration != null
                                          ? timeFormat(_data.songDuration)
                                          : '0:00',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)))
                                ],
                              ),
                            ),
                            Container(
                                height: screenHeight * 0.1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _data.currentSong != null
                                          ? _data.currentSong.title
                                          : '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.03,
                                          color:
                                              Color.fromRGBO(200, 200, 200, 1)),
                                    ),
                                    Text(
                                      _data.currentSong != null
                                          ? _data.currentSong.artist
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
                                        onPressed: _data.currentSong != null
                                            ? () {
                                                if (sliderValue < 0.2) {
                                                  _data.seek();
                                                } else {
                                                  _data.prev();
                                                }
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: Colors.grey,
                                          size: screenHeight * 0.07,
                                        )),
                                    IconButton(
                                      onPressed: _data.currentSong != null
                                          ? () async {
                                              if (_data.playerState ==
                                                  AudioPlayerState.PLAYING) {
                                                await _data.playerPause();
                                              } else {
                                                _data.playerResume();
                                              }
                                            }
                                          : null,
                                      icon: Icon(
                                        _data.playerState ==
                                                AudioPlayerState.PLAYING
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.grey,
                                        size: screenHeight * 0.07,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: _data.currentSong != null
                                            ? () {
                                                _data.next();
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
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: _data.repeatClick,
                                              icon: Icon(Icons.repeat,
                                                  size: screenHeight * 0.03,
                                                  color: _data.repeat
                                                      ? Colors.redAccent
                                                      : Colors.grey),
                                            ),
                                            IconButton(
                                              onPressed:
                                                  _addToPlaylistShowDialog,
                                              icon: Icon(Icons.playlist_add,
                                                  size: screenHeight * 0.03,
                                                  color: Colors.grey),
                                            ),
                                            IconButton(
                                              onPressed: _data.mixClick,
                                              icon: Icon(Icons.shuffle,
                                                  size: screenHeight * 0.03,
                                                  color: Colors.grey),
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
