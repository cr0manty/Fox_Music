import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:connectivity/connectivity.dart';
import 'package:vk_parse/api/authCheck.dart';
import 'package:vk_parse/functions/save/logout.dart';

import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/api/profile.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class AccountData with ChangeNotifier {
  User user;
  File newImage;
  bool offlineMode = false;
  AccountType accountType;

  AccountData() {
    accountType = AccountType.SELF_SHOW;
  }

  init() async {
    if (!await authCheckGet()) {
      await makeLogout();
    } else {
      user = await profileGet();
    }
    final connection = await Connectivity().checkConnectivity();
    offlineMode = connection == ConnectivityResult.none;
  }

  changeAccountState() {
    accountType = accountType == AccountType.SELF_SHOW
        ? AccountType.SELF_EDIT
        : AccountType.SELF_SHOW;
    notifyListeners();
  }

  updateUserData(data) async {
    if (await profilePost(body: data)) {
      User newUser = await profileGet();
      if (newUser != null) {
        user = newUser;
      }
      changeAccountState();
      notifyListeners();
    }
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

  prev() {
    notifyListeners();
  }

  next() {
    notifyListeners();
  }
}
