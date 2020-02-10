import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/format/formatTime.dart';

import 'package:vk_parse/models/Song.dart';


class MusicData with ChangeNotifier {
  AudioPlayer audioPlayer;
  Song currentSong;
  bool repeat = false;
  bool offlineMode = false;
  List<Song> forPlaySong = [];
  List<Song> playlist = [];
  List<Song> localSongs = [];

  Duration songPosition;
  Duration songDuration;
  var platform;

  AudioPlayerState playerState;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;

  MusicData() {
    playerState = AudioPlayerState.STOPPED;
  }

  init(thisPlatform) async {
    platform = thisPlatform;
    await initPlayer();
    await _setPlaylist();
    await loadSavedMusic();
  }

  initPlayer() {
    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
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

  setCCData() {
    if (platform == TargetPlatform.iOS) {
      audioPlayer.startHeadlessService();

      audioPlayer.setNotification(
          title: currentSong.title,
          artist: currentSong.artist,
          imageUrl: '',
          forwardSkipInterval: const Duration(seconds: 5),
          backwardSkipInterval: const Duration(seconds: 5),
          duration: songDuration,
          elapsedTime: Duration(seconds: 0));
    }
  }

  loadSavedMusic() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }

    final fileList = Directory("$directory/songs/").listSync();
    fileList.forEach((songPath) {
      final song = formatSong(songPath.path);
      if (song != null) localSongs.add(song);
    });
  }

  _setPlaylist() {
    if (forPlaySong == null) {
      forPlaySong = (playlist != null ? playlist : localSongs);
    }
  }

  mixClick() {
    forPlaySong..shuffle();
    notifyListeners();
  }

  repeatClick() async {
    repeat = !repeat;
    if (repeat) {
      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
    notifyListeners();
  }

  playlistAddClick() {
    notifyListeners();
  }
  playerPlay(Song song) async {
    audioPlayer.play(song.path);
    currentSong = song;
    setCCData();
    notifyListeners();
  }

  playerStop() async {
    audioPlayer.stop();
    playerState = AudioPlayerState.STOPPED;
    notifyListeners();
  }

  playerResume() async {
    audioPlayer.resume();
    playerState = AudioPlayerState.PLAYING;
    notifyListeners();
  }

  playerPause() async {
    audioPlayer.pause();
    playerState = AudioPlayerState.PAUSED;
    notifyListeners();
  }

  prev() {
    notifyListeners();
  }

  next() {
    notifyListeners();
  }

  seek({duration}) {
    if (currentSong != null) {
      int value = (duration != null && duration < 1
              ? durToInt(songDuration) * duration
              : 0)
          .toInt();
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
