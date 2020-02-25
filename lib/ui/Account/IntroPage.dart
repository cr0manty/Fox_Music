import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/provider/AccountData.dart';

import 'package:vk_parse/provider/MusicData.dart';
import 'package:vk_parse/provider/MusicDownloadData.dart';
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
      MusicData musicData = new MusicData();
      AccountData accountData = new AccountData();
      MusicDownloadData downloadData = new MusicDownloadData();
      await musicData.init(Theme.of(context).platform);
      await accountData.init();
      await downloadData.init();

      Navigator.popUntil(context, (Route<dynamic> route) => true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => MultiProvider(providers: [
                    ChangeNotifierProvider<MusicData>.value(value: musicData),
                    ChangeNotifierProvider<AccountData>.value(
                        value: accountData),
                    ChangeNotifierProvider<MusicDownloadData>.value(
                        value: downloadData),
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
    return Scaffold(
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
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 5),
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.7),
                                      BlendMode.dstIn),
                                  image:
                                      AssetImage('assets/images/app-logo.png'),
                                  fit: BoxFit.fitWidth)))),
                ),
                Center(
                    child: Padding(
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
