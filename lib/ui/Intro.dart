import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:vk_parse/functions/get/getToken.dart';
import 'package:vk_parse/functions/get/getLastRoute.dart';
import 'package:vk_parse/api/requestAuthCheck.dart';
import 'package:vk_parse/functions/save/logout.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final int splashDuration = 2;

  startTime() {
    return Timer(Duration(seconds: splashDuration), () async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      bool needToken = false;
      final lastPage = await getLastRoute();
      if (lastPage != '/Login' && lastPage != '/MusicListSaved') {
        if (!await requestAuthCheck()) {
          await logout();
        }
        final token = await getToken();
        if (token == null || token.length == 0) {
          needToken = true;
        }
      }
      Navigator.of(context)
          .pushReplacementNamed(needToken ? '/Login' : lastPage);
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
                    "© Cr0manty 2019",
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
