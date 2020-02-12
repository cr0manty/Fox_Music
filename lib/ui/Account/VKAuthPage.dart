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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('VK Auth'), centerTitle: true),
      body: Container(),
    );
  }



}
