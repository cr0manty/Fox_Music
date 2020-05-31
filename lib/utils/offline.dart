import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';

import 'border_button.dart';
import 'hex_color.dart';

class OfflinePage extends StatefulWidget {
  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  double buttonOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: Container(
            alignment: Alignment.center,
            color: HexColor('#8c8c8c').withOpacity(0.2),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'You are offline',
                        style: TextStyle(color: HexColor('#cccccc')),
                      ),
                      SizedBox(height: 20),
                      BorderButton(
                          text: 'Settings',
                          color: HexColor('#cccccc'),
                          onPressed: AppSettings.openLocationSettings)
                    ]))));
  }
}
