import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/utils/hex_color.dart';

class MusicTextPage extends StatefulWidget {
  final String songText;

  MusicTextPage({this.songText});

  @override
  State<StatefulWidget> createState() => MusicTextState();
}

class MusicTextState extends State<MusicTextPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Lyrics'),
            previousPageTitle: 'Back',
            trailing: GestureDetector(
                child: Text('Edit', style: TextStyle(color: main_color),),
                onTap: () {})), child: Container());
  }
}
