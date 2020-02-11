import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vk_parse/ui/Account/IntroPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'VK Music',
      theme: ThemeData(
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.grey,
          fontFamily: 'Georgia',
          accentColor: Colors.redAccent),
      home: IntroPage(),
    );
  }
}
