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
  bool edit;

  @override
  void initState() {
    edit = false;
    super.initState();
  }

  _saveSongText() {}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: true,
        navigationBar: CupertinoNavigationBar(
            middle: Text('Lyrics'),
            previousPageTitle: 'Back',
            trailing: GestureDetector(
                child: Container(
                    color: Colors.transparent,
                    child: Text(
                      edit ? 'Save' : 'Edit',
                      style: TextStyle(color: main_color),
                    )),
                onTap: () {
                  if (edit) _saveSongText();
                  setState(() {
                    edit = !edit;
                  });
                })),
        child: Stack(
          children: <Widget>[
            SafeArea(
                child: Material(
                    color: HexColor('#1c1c1c'),
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      cursorColor: main_color,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(9.0),
                            ),
                          ),
                          focusColor: main_color,
                          fillColor: main_color,
                          hoverColor: main_color),
                      maxLines: 100,
                    )))
          ],
        ));
  }
}
