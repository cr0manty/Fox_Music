import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/utils/hex_color.dart';

class AppleSearch extends StatefulWidget {
  final ValueChanged<String> onChange;
  final TextEditingController controller;

  AppleSearch({@required this.controller, this.onChange});

  @override
  State<StatefulWidget> createState() => AppleSearchState();
}

class AppleSearchState extends State<AppleSearch> {
  FocusNode _searchFocus = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      hasFocus = _searchFocus.hasFocus;
    });
  }

  void _clearController() {
    widget.controller.clear();
    widget.onChange('');
  }

  Widget build(BuildContext context) {
    double width = hasFocus
        ? MediaQuery.of(context).size.width * 0.8
        : MediaQuery.of(context).size.width;
    return Stack(children: <Widget>[
      Container(
          width: width,
          padding: EdgeInsets.all(10),
          child: CupertinoTextField(
            controller: widget.controller,
            suffixMode: OverlayVisibilityMode.editing,
            suffix: GestureDetector(
                onTap: () => _clearController(),
                child: Container(
                  alignment: Alignment.center,
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      SFSymbols.multiply_circle_fill,
                      color: Colors.grey,
                      size: 20,
                    ))),
            prefix: Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Icon(
                  Icons.search,
                  color: Colors.grey,
                )),
            onChanged: widget.onChange,
            focusNode: _searchFocus,
            placeholder: 'Search',
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: HexColor('#191919').withOpacity(0.9)),
          )),
      hasFocus
          ? GestureDetector(
              onTap: () {
                _searchFocus.unfocus();
                _clearController();
              },
              child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.all(16),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: HexColor.main(),
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  )),
            )
          : Container()
    ]);
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }
}
