import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';

import 'package:vk_parse/api/requestProfile.dart';
import 'package:vk_parse/functions/get/getLastFriendId.dart';
import 'package:vk_parse/functions/get/getToken.dart';
import 'package:vk_parse/functions/get/getLastRoute.dart';
import 'package:vk_parse/api/requestAuthCheck.dart';
import 'package:vk_parse/functions/save/logout.dart';
import 'package:vk_parse/functions/save/saveCurrentUser.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/utils/routes.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => new _IntroState();
}

class _IntroState extends State<Intro> {
  final int splashDuration = 1;
  final AudioPlayer _audioPlayer =
      AudioPlayer(playerId: 'usingThisIdForPlayer');

  startTime() async {
    return Timer(Duration(seconds: splashDuration), () async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      bool offlineMode;
      int lastPage;
      User lastUser;
      User friend;

      final connection = await Connectivity().checkConnectivity();
      offlineMode = connection == ConnectivityResult.none ? true : false;

      if (!offlineMode) {
        lastPage = await getLastRoute();
        if (lastPage != null) {
          if (!await requestAuthCheck()) {
            await logout();
          }
          final token = await getToken();
          if (token == null || token.length == 0) {
            lastPage = null;
          }
        }
      } else {
        lastPage = 1;
      }
      if (lastPage != null) {
        if (lastPage > 0 && lastPage < 4) {
          lastUser = await requestProfileGet();
          saveCurrentUser(lastUser);
        } else if (lastPage == 4) {
          int lastFriendId = await getLastFriendId();
          friend = await requestProfileGet(friendId: lastFriendId);
        }
      }
      Navigator.popUntil(context, (Route<dynamic> route) => true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => switchRoutes(_audioPlayer,
                  user: lastUser,
                  offline: offlineMode,
                  route: lastPage,
                  friend: friend)),
          (Route<dynamic> route) => false);
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
