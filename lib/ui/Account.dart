import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/models/User.dart';

class Account extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountState();
  }
}

enum AccountType { self, friend, another }

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Account', _menuKey),
      backgroundColor: lightGrey,
    );
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute('/Account');
  }
}
