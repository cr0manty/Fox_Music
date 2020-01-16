import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:vk_parse/functions/get/getToken.dart';
import 'package:vk_parse/functions/get/getLastRoute.dart';
import 'package:vk_parse/api/requestAuthCheck.dart';
import 'package:vk_parse/functions/save/logout.dart';
import 'package:vk_parse/utils/routes.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => new _IntroState();
}

class _IntroState extends State<Intro> {
  final int splashDuration = 2;
  final AudioPlayer _audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');

  startTime() {
    return Timer(Duration(seconds: splashDuration), () async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      bool offlineMode = false;

      int lastPage = await getLastRoute();
      if (lastPage != null && !offlineMode) {
        if (!await requestAuthCheck()) {
          await logout();
        }
        final token = await getToken();
        if (token == null || token.length == 0) {
          lastPage = null;
        }
      }
      final String directory = (await getApplicationDocumentsDirectory()).path;
      final documentDir = new Directory("$directory/songs/");
      if (!documentDir.existsSync()) {
        documentDir.createSync();
      }

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              switchRoutes(_audioPlayer, offline: offlineMode)));
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    var drawer = Drawer();
    return Scaffold(
        drawer: drawer,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/intro-background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: FractionalOffset(0.5, 0.3),
                    child: Text(
                      "VK Music",
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                  ),
                ),
                Center(
                    child: new Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: SpinKitCircle(
                          color: Colors.white,
                          size: 80,
                        ))),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                  child: Text(
                    "© Cr0manty 2020",
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )));
  }
}
