import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vk_parse/ui/Account/IntroPage.dart';
import 'package:vk_parse/utils/hex_color.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return CupertinoApp(
      key: _scaffoldKey,
      debugShowCheckedModeBanner: false,
      title: 'VK Music',
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: HexColor('#282828')
      ),


      home: IntroPage(),
    );
  }
}
