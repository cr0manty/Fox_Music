import 'package:flutter/cupertino.dart';

class KeyHolder {
  static final KeyHolder _singleton = new KeyHolder._internal();

  factory KeyHolder() {
    return _singleton;
  }
  GlobalKey<NavigatorState> key = new GlobalKey<NavigatorState>();

  KeyHolder._internal();
}