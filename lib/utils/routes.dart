import 'package:flutter/material.dart';

import 'package:vk_parse/ui/MusicListRequest.dart';
import 'package:vk_parse/ui/MusicListSaved.dart';
import 'package:vk_parse/ui/Account.dart';
import 'package:vk_parse/ui/FriendList.dart';
import 'package:vk_parse/ui/Login.dart';

var routes = <String, WidgetBuilder>{
  "/Login": (BuildContext context) => Login(),
  "/MusicListRequest": (BuildContext context) => MusicListRequest(),
  "/MusicListSaved": (BuildContext context) => MusicListSaved(),
  "/Account": (BuildContext context) => Account(),
  "/FriendList": (BuildContext context) => FriendList(),
};
