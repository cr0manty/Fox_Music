import 'package:flutter/material.dart';
import 'package:weather_app/utils/hex_color.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Widget _menuButton() {
    return GestureDetector(
      child: Container(
        child: Icon(Icons.menu),
      ),
    );
  }

  Widget _todayTimes() {
    return Row(
      children: <Widget>[],
    );
  }

  Widget _graphic() {
    return Container();
  }

  Widget _weatherContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.ac_unit,
            size: MediaQuery.of(context).size.height * 0.35 * 0.3,
          ),
          Container(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '-1',
                style: Theme.of(context).textTheme.headline1,
              ),
              Text('Snow', style: Theme.of(context).textTheme.headline6)
            ],
          )
        ],
      ),
    );
  }

  Widget _appBar() {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Kharkov',
                  style: Theme.of(context).textTheme.headline1,
                ),
                _menuButton()
              ],
            ),
            Text(
              'Ukraine',
              style: Theme.of(context).textTheme.headline1,
            ),
            Text(
              'Sunday, 1 AM',
              style: Theme.of(context).textTheme.headline3,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: HexColor('#22252b')),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _appBar(),
          _weatherContainer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Today', style: Theme.of(context).textTheme.headline6),
          ),
          _todayTimes(),
          _graphic()
        ],
      ),
    ));
  }
}
