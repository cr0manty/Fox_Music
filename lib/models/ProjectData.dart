import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:connectivity/connectivity.dart';
import 'package:vk_parse/api/requestAuthCheck.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
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
  List<Song> forPlaySong;
  List<Song> localSongs;

  Duration songPosition;
  Duration songDuration;

  AudioPlayerState playerState;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;

  ProjectData() {
    accountType = AccountType.SELF_SHOW;
    playerState = AudioPlayerState.STOPPED;
  }

  init(platform) async {
    initPlayer(platform);
    if (!await requestAuthCheck()) {
      await makeLogout();
    } else {
      user = await requestProfileGet();
    }
    final connection = await Connectivity().checkConnectivity();
    offlineMode = connection == ConnectivityResult.none;
  }

  initPlayer(platform) {
    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;

      if (platform == TargetPlatform.iOS) {
        audioPlayer.startHeadlessService();

        audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30),
            backwardSkipInterval: const Duration(seconds: 30),
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
      notifyListeners();
    });
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      songPosition = p;
      notifyListeners();
    });
    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      songPosition = null;
      playerState = AudioPlayerState.STOPPED;
      notifyListeners();
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      playerState = state;
      notifyListeners();
    });

    audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      playerState = state;
      notifyListeners();
    });
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

  playerPlay(path) async {
    audioPlayer.play(path);
    notifyListeners();
  }

  playerStop() async {
    audioPlayer.stop();
    notifyListeners();
  }

  playerResume() async {
    audioPlayer.resume();
    notifyListeners();
  }

  playerPause() async {
    audioPlayer.pause();
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

  prev() {
    notifyListeners();
  }

  next() {
    notifyListeners();
  }

  seek({duration}) {
    if (currentSong != null && duration < 1) {
      int value =
          (duration != null ? durToInt(songDuration) * duration : 0).toInt();
      audioPlayer.seek(Duration(seconds: value));
      notifyListeners();
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }
}
