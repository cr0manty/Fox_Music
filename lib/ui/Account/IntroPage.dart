import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/provider/AccountData.dart';

import 'package:vk_parse/provider/MusicData.dart';
import 'package:vk_parse/ui/MainPage.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => new _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final int splashDuration = 1;

  startTime() async {
    return Timer(Duration(seconds: splashDuration), () async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      final musicData = new MusicData();
      final userData = new AccountData();
      await musicData.init(Theme.of(context).platform);
      await userData.init();

      Navigator.popUntil(context, (Route<dynamic> route) => true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => MultiProvider(providers: [
                    ChangeNotifierProvider<MusicData>.value(value: musicData),
                    ChangeNotifierProvider<AccountData>.value(value: userData),
                  ], child: MainPage())),
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
