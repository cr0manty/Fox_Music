import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TileList extends StatefulWidget {
  final Key key;
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Function onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  TileList(
      {this.key,
      this.title,
      this.subtitle,
      this.onTap,
      this.leading,
      this.trailing,
      this.margin,
      this.padding});

  @override
  State<StatefulWidget> createState() => TileListState();
}

class TileListState extends State<TileList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: widget.key,
        onTap: widget.onTap,
        child: Container(
            color: Colors.transparent,
            padding: widget.padding ?? EdgeInsets.all(8),
            margin: widget.margin != null
                ? widget.margin
                : widget.padding != null
                    ? EdgeInsets.symmetric(vertical: 8)
                    : EdgeInsets.zero,
            alignment: Alignment.center,
            child: Center(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                widget.leading ?? Container(),
                Flexible(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    widget.title ?? Container(),
                    Divider(height: 2, color: Colors.transparent),
                    widget.subtitle ?? Container()
                  ],
                )),
                SizedBox(),
                Container(
                      child: widget.trailing,
                      margin: EdgeInsets.all(2),
                    ) ??
                    Container()
              ],
            ))));
  }
}
