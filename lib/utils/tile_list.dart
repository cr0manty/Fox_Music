import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TileList extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Function onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  TileList(
      {this.title,
      this.subtitle,
      this.onTap,
      this.leading,
      this.trailing,
      this.margin,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
            padding: padding ?? EdgeInsets.all(16),
            margin: margin ?? padding != null
                ? EdgeInsets.symmetric(vertical: 8)
                : EdgeInsets.zero,
            alignment: Alignment.center,
            child: Center(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                leading ?? Container(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    title ?? Container(),
                    Divider(height: 2, color: Colors.transparent),
                    subtitle ?? Container()
                  ],
                ),
                Expanded(child: SizedBox()),
                trailing ?? Container()
              ],
            ))));
  }
}
