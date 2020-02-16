import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vk_parse/ui/Account/IntroPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      key: _scaffoldKey,
      debugShowCheckedModeBanner: false,
      title: 'VK Music',
      theme: ThemeData(
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.grey,
          fontFamily: 'Georgia',
          textSelectionHandleColor: Colors.redAccent,
          accentColor: Colors.redAccent),
      home: IntroPage(),
    );
  }
}
