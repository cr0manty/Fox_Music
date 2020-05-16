import 'package:flutter/material.dart';
import 'package:weather_app/screens/weather_day.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 40, color: Colors.white),
            headline3:
                TextStyle(fontSize: 25, color: Colors.white.withOpacity(0.8)),
          )),
      themeMode: ThemeMode.dark,
      home: WeatherPage(),
    );
  }
}
