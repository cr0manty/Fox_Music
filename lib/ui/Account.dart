import 'package:flutter/material.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

import 'package:vk_parse/widgets/AppBarDrawer.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/models/User.dart';

class Account extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AccountState();
}

enum AccountType { self, friend, request, block, send_request }

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  User _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
//      drawer: AppBarDrawer(),
      appBar: makeAppBar('User account', _menuKey),
      backgroundColor: lightGrey,
    );
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute(route: 2);
  }
}
