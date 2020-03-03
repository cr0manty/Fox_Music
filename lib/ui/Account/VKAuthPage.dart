import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vk_parse/provider/AccountData.dart';

class VKAuthPage extends StatefulWidget {
  final AccountData accountData;

  VKAuthPage(this.accountData);

  @override
  State<StatefulWidget> createState() => new VKAuthState();
}

class VKAuthState extends State<VKAuthPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: _scaffoldKey,
      navigationBar: CupertinoNavigationBar(
          middle: Text('Auth'), previousPageTitle: 'Back'),
      child: Container(),
    );
  }
}
