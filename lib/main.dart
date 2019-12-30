import 'package:flutter/material.dart';

import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/ui/MusicListRequest.dart';
import 'package:vk_parse/ui/Login.dart';
import 'package:vk_parse/ui/Intro.dart';


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
        "/MusicListRequest": (BuildContext context) => MusicListRequest(),
        "/Login": (BuildContext context) => Login(),
      },
      home: Intro(),
    );
  }
}

