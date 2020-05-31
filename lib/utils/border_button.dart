import 'package:flutter/cupertino.dart';

import 'hex_color.dart';

class BorderButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  BorderButton({@required this.text, @required this.onPressed, @required this.color});

  @override
  _BorderButtonState createState() => _BorderButtonState();
}

class _BorderButtonState extends State<BorderButton> {
  double buttonOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (details) => setState(() {
              buttonOpacity = 0.5;
            }),
        onTapCancel: () => setState(() {
              buttonOpacity = 1.0;
            }),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: widget.color.withOpacity(buttonOpacity)),
                borderRadius: BorderRadius.circular(5)),
            child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onPressed: widget.onPressed,
                child: Text(
                  widget.text,
                  style: TextStyle(color: widget.color, fontSize: 15),
                ))));
  }
}
