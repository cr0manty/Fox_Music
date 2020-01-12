import 'package:flutter/material.dart';

import 'package:vk_parse/ui/MusicList.dart';
import 'package:vk_parse/ui/Account.dart';
import 'package:vk_parse/ui/FriendList.dart';
import 'package:vk_parse/ui/Login.dart';


routes() => <String, WidgetBuilder>{
  "/Login": (BuildContext context) => Login(),
  "/MusicList": (BuildContext context) => MusicList(),
  "/Account": (BuildContext context) => Account(),
  "/FriendList": (BuildContext context) => FriendList(),
};
