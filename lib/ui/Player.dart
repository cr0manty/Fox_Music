import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:audioplayers/audioplayers.dart';

class Player extends StatelessWidget {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  Song currentSong;
  AudioPlayerState _songState = AudioPlayerState.STOPPED;

  @override
  Widget build(BuildContext context) {
    double pictureHeight = MediaQuery.of(context).size.height * 0.55;
    final _data = Provider.of<ProjectData>(context);
    FocusScope.of(context).requestFocus(FocusNode());
    return Scaffold(
        key: _menuKey,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                height: pictureHeight,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: pictureHeight,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  Image.asset('assets/images/user-default.jpg')
                                      .image,
                              fit: BoxFit.cover)),
                    ),
                    Container(
                      height: pictureHeight,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Colors.redAccent.withOpacity(0.2),
                            Color.fromRGBO(35, 35, 35, 1)
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    ),
                  ],
                )),
            Container(
              child: Slider(
                onChanged: (double value) {},
                value: 0,
                activeColor: Colors.redAccent,
                inactiveColor: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(currentSong != null ? '0:00' : '0:00',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  Text(
                      currentSong != null
                          ? currentSong.duration.toString()
                          : '0:00',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)))
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.all(15.0),
                height: MediaQuery.of(context).size.height * 0.1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSong != null ? currentSong.title : 'sadasd',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    Text(
                      currentSong != null ? currentSong.artist : 'asdsad',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    )
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.only(top: 17),
                  onPressed: _data.repeatClick,
                  icon: Icon(Icons.repeat,
                      size: 25, color: _data.repeat ? Colors.redAccent : Colors.grey),
                ),
                IconButton(
                    onPressed: currentSong != null ? null : null,
                    icon: Icon(
                      Icons.fast_rewind,
                      color: currentSong != null
                          ? Colors.grey
                          : Color.fromRGBO(60, 60, 60, 1),
                      size: 50,
                    )),
                IconButton(
                  onPressed: currentSong != null ? null : null,
                  icon: Icon(
                    _songState == AudioPlayerState.PLAYING
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: currentSong != null
                        ? Colors.grey
                        : Color.fromRGBO(60, 60, 60, 1),
                    size: 50,
                  ),
                ),
                IconButton(
                    onPressed: currentSong != null ? null : null,
                    icon: Icon(
                      Icons.fast_forward,
                      color: currentSong != null
                          ? Colors.grey
                          : Color.fromRGBO(60, 60, 60, 1),
                      size: 50,
                    )),
                IconButton(
                  padding: EdgeInsets.only(top: 17, right: 15),
                  onPressed: _data.mixClick,
                  icon: Icon(Icons.shuffle,
                      size: 30, color: _data.mix ? Colors.redAccent : Colors.grey),
                )
              ],
            ),
          ],
        ));
  }
}
