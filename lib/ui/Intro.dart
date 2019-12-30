import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vk_parse/functions/getToken.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final int splashDuration = 2;

  startTime() async {
    final token = await getToken();
    return Timer(Duration(seconds: splashDuration), () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      if (token.length > 0) {
        Navigator.of(context).pushReplacementNamed('/MusicListRequest');
      } else {
        Navigator.of(context).pushReplacementNamed('/Login');
      }
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
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue),
                    alignment: FractionalOffset(0.5, 0.3),
                    child: Text(
                      "VK Music",
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                  child: Text(
                    "© Cr0manty 2019",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )));
  }
}
