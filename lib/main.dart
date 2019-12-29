import 'package:flutter/material.dart';
import 'package:vk_parse/ui/MusicList.dart';
import 'package:vk_parse/ui/Login.dart';
import 'utils/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VK Music',
      theme: ThemeData(
        primarySwatch: primaryBlack,
        primaryTextTheme: TextTheme(
          title: TextStyle(color:Colors.white)
        )
      ),
      routes: <String,WidgetBuilder>{
        "/home": (BuildContext context) => MusicList(),
        "/login": (BuildContext context) => Login(),
      },
      home: Login(),
    );
  }
}

