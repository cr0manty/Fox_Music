import 'package:flutter/material.dart';
import 'package:vk_parse/MusicListPage.dart';
import 'package:vk_parse/LoginPage.dart';
import 'colors.dart';

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
      home: LoginPage(),
    );
  }
}

