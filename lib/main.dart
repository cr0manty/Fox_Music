import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file:///C:/Users/Cr0manty/AndroidStudioProjects/Fox_Music/lib/ui/splash_screen.dart';
import 'package:fox_music/utils/hex_color.dart';

void main() => runApp(FoxMusic());

class FoxMusic extends StatefulWidget {
  @override
  FoxMusicState createState() => FoxMusicState();
}

class FoxMusicState extends State<FoxMusic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return CupertinoApp(
      key: _scaffoldKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        primaryColor: Color.fromRGBO(193, 39, 45, 1),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: HexColor('#222222')),
      home: IntroPage(),
    );
  }
}
