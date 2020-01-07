import 'package:flutter/material.dart';

import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/utils/routes.dart';
import 'package:vk_parse/ui/Intro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VK Music',
      theme: ThemeData(
          primarySwatch: primaryBlack,
          primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white))),
      routes: routes(),
      home: Intro(),
    );
  }
}
