import 'package:flutter/material.dart';

class WeatherScaffold extends StatefulWidget {
  final Widget body;
  final Widget background;

  WeatherScaffold({@required this.body, @required this.background});

  @override
  _WeatherScaffoldState createState() => _WeatherScaffoldState();
}

class _WeatherScaffoldState extends State<WeatherScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: widget.background,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: widget.body,
          ),
        ],
      ),
    );
  }
}
