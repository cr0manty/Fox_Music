import 'package:flutter/material.dart';

import 'package:vk_parse/ui/AppBar.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';

class Account extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountState();
  }
}

enum AccountType { self, friend, another }

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> menuKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: menuKey,
      drawer: makeDrawer(context),
      appBar: makeAppBar('Account', menuKey),
      backgroundColor: lightGrey,
    );
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute('/Account');
  }
}
