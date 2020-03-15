import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:connectivity/connectivity.dart';
import 'package:fox_music/api/auth.dart';
import 'package:fox_music/api/friends_list.dart';
import 'package:fox_music/functions/save/logout.dart';
import 'package:fox_music/models/relationship.dart';

import 'package:fox_music/models/user.dart';
import 'package:fox_music/api/profile.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class AccountData with ChangeNotifier {
  List<Relationship> friendList = [];
  User user;
  File newImage;
  bool offlineMode = false;
  AccountType accountType;
  int messageCount = 0;

  AccountData() {
    accountType = AccountType.SELF_SHOW;
  }

  init() async {
    if (!await authCheckGet()) {
      await makeLogout();
    } else {
      user = await profileGet();
    }
    await loadFiendList();
    final connection = await Connectivity().checkConnectivity();
    offlineMode = connection == ConnectivityResult.none;
  }

  loadFiendList() async {
    friendList = await friendListGet();
    notifyListeners();
  }

  updateUserData(data) async {
    bool profile = await profilePost(body: data);
    if (profile) {
      User newUser = await profileGet();
      if (newUser != null) {
        user = newUser;
      }
      notifyListeners();
    }
  }

  getUser({int userId}) async {
    User newUser = await profileGet(friendId: userId);
    if (newUser != null) {
      user = newUser;
    }
    notifyListeners();
  }

  setUser(newUser) {
    user = newUser;
    notifyListeners();
  }

  makeLogout() {
    logout();
    setUser(null);
  }

  setNewImage(image) {
    newImage = image;
    notifyListeners();
  }
}
