import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:connectivity/connectivity.dart';
import 'package:vk_parse/api/requestAuthCheck.dart';
import 'package:vk_parse/functions/save/logout.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/api/requestProfile.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class ProjectData with ChangeNotifier {
  AudioPlayer audioPlayer;
  Song currentSong;
  User user;
  bool repeat = false;
  bool mix = false;
  File newImage;
  bool offlineMode = false;
  AccountType accountType;

  ProjectData() {
    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
    accountType = AccountType.SELF_SHOW;
  }

  init() async {
    if (!await requestAuthCheck()) {
      await makeLogout();
    } else {
      user = await requestProfileGet();
    }
    final connection = await Connectivity().checkConnectivity();
    offlineMode = connection == ConnectivityResult.none;
  }

  mixClick() {
    mix = !mix;
    notifyListeners();
  }

  repeatClick() {
    repeat = !repeat;
    notifyListeners();
  }

  changeAccountState() {
    accountType = accountType == AccountType.SELF_SHOW
        ? AccountType.SELF_EDIT
        : AccountType.SELF_SHOW;
    notifyListeners();
  }

  updateUserData(data) async {
    if (await requestProfilePost(body: data)) {
      User newUser = await requestProfileGet();
      if (newUser != null) {
        user = newUser;
      }
      changeAccountState();
      notifyListeners();
    }
  }

  playerPlay(path, {isLocal}) async {
    isLocal = isLocal != null ? isLocal : false;
    await audioPlayer.play(path, isLocal: isLocal);
    notifyListeners();
  }

  playerStop() async {
    await audioPlayer.resume();
    notifyListeners();
  }

  playerResume() async {
    await audioPlayer.resume();
    notifyListeners();
  }

  playerPause() async {
    await audioPlayer.pause();
    notifyListeners();
  }

  setPlayedSong(song) {
    currentSong = song;
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
