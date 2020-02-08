import 'package:flutter/material.dart';
import 'package:vk_parse/ui/Intro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VK Music',
      theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.redAccent,),
      home: Intro(),
    );
  }
}
