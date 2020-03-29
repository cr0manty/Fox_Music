import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/provider/database.dart';
import 'package:fox_music/utils/hex_color.dart';

class MusicTextPage extends StatefulWidget {
  final String songText;
  final int songId;

  MusicTextPage({this.songText, this.songId});

  @override
  State<StatefulWidget> createState() => MusicTextState();
}

class MusicTextState extends State<MusicTextPage> {
  TextEditingController controller;
  FocusNode _focus;
  bool edit;

  @override
  void initState() {
    controller = TextEditingController();
    _focus = FocusNode();
    controller.text = widget.songText;
    edit = false;
    super.initState();
  }

  void _editTap() async {
    if (edit) {
      await DBProvider.db.songLyricsUpdate(widget.songId, controller.text);
      setState(() {
        edit = false;
      });
    } else {
      setState(() {
        edit = !edit;
        _focus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
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
                onTap: _editTap)),
        child: Stack(
          children: <Widget>[
            SafeArea(
                child: Material(
                    color: HexColor('#1c1c1c'),
                    child: TextField(
                      controller: controller,
                      focusNode: _focus,
                      enabled: edit,
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      cursorColor: main_color,
                      autofocus: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(9.0),
                            ),
                          ),
                          focusColor: main_color,
                          fillColor: main_color,
                          hoverColor: main_color),
                      maxLines: 200,
                    )))
          ],
        ));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }
}
