import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/functions/get/last_tab.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/provider/account_data.dart';

import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/main_tab.dart';
import 'package:fox_music/utils/hex_color.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => new _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final int splashDuration = 1;

  startTime() async {
    return Timer(Duration(seconds: splashDuration), () async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      int lastIndex = await getLastTab();
      MusicData musicData = new MusicData();
      AccountData accountData = new AccountData();
      MusicDownloadData downloadData = new MusicDownloadData();
      musicData.init(Theme.of(context).platform);
      accountData.init();
      downloadData.init();

      Navigator.popUntil(context, (Route<dynamic> route) => true);
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
              builder: (BuildContext context) => MultiProvider(providers: [
                    ChangeNotifierProvider<MusicData>.value(value: musicData),
                    ChangeNotifierProvider<AccountData>.value(
                        value: accountData),
                    ChangeNotifierProvider<MusicDownloadData>.value(
                        value: downloadData),
                  ], child: MainPage(lastIndex))),
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
    return CupertinoPageScaffold(
      backgroundColor:
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark
              ? HexColor('#282828')
              : Colors.white,
      child: Container(),
    );
  }
}
