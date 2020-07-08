import 'dart:async';
import 'dart:io';
import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/instances/shared_prefs.dart';

import 'api.dart';
import 'check_connection.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class AccountData {
  AccountData._internal();

  static final AccountData _instance = AccountData._internal();

  static AccountData get instance => _instance;

  List<Relationship> friendList = [];
  User _user;
  File newImage;
  AccountType accountType = AccountType.SELF_SHOW;

  Stream<bool> get onUserChangeAccount => _userChangeAccount.stream;

  final StreamController<bool> _userChangeAccount =
      StreamController<bool>.broadcast();

  init() async {
    if (ConnectionsCheck.instance.isOnline) {
      User newUser = await Api.profileGet();
      if (newUser != null) {
        user = newUser;
        loadFiendList();
        SharedPrefs.saveUser(user);
      } else {
        await makeLogout();
      }
    } else {
      user = SharedPrefs.getUser();
    }
  }

  loadFiendList() async {
    friendList = await Api.friendListGet();
  }

  updateUserData(data) async {
    bool profile = await Api.profilePost(body: data);
    if (profile) {
      User newUser = await Api.profileGet();
      if (newUser != null) {
        user = newUser;
        SharedPrefs.saveUser(user);
      }
    }
  }

  getUserProfile({int userId}) async {
    User newUser = await Api.profileGet(friendId: userId);
    if (newUser != null) {
      user = newUser;
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
  }

  void dispose() {
    _userChangeAccount?.close();
  }
}
