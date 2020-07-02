import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/provider/shared_prefs.dart';

import 'api.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class AccountData with ChangeNotifier {
  List<Relationship> friendList = [];
  User _user;
  File newImage;
  bool offlineMode = false;
  AccountType accountType = AccountType.SELF_SHOW;
  bool needUpdate = true;

  Stream<bool> get onUserChangeAccount => _userChangeAccount.stream;

  final StreamController<bool> _userChangeAccount =
      StreamController<bool>.broadcast();

  init(bool isOnline) async {
    if (isOnline) {
      if (await Api.authCheckGet()) {
        user = await Api.profileGet();
        if (user == null) {
          await makeLogout();
        } else {
          needUpdate = false;
          await loadFiendList();
          SharedPrefs.saveUser(user);
        }
      }
    } else {
      User newUser = SharedPrefs.getUser();
      user = newUser;
    }
    offlineMode = !isOnline;
  }

  loadFiendList() async {
    friendList = await Api.friendListGet();
    notifyListeners();
  }

  updateUserData(data) async {
    bool profile = await Api.profilePost(body: data);
    if (profile) {
      User newUser = await Api.profileGet();
      if (newUser != null) {
        user = newUser;
        SharedPrefs.saveUser(user);
      }
      notifyListeners();
    }
  }

  getUserProfile({int userId}) async {
    User newUser = await Api.profileGet(friendId: userId);
    if (newUser != null) {
      _user = newUser;
    }
  }

  set user(User newUser) {
    _user = newUser;
    _userChangeAccount.add(_user != null);
  }

  User get user => _user;

  makeLogout() {
    SharedPrefs.logout();
    user = null;
  }

  setNewImage(image) {
    newImage = image;
    notifyListeners();
  }

  @override
  void dispose() {
    _userChangeAccount?.close();
    super.dispose();
  }
}
