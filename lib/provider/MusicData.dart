import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/get/getPlayerState.dart';
import 'package:vk_parse/functions/save/savePlayerState.dart';

import 'package:vk_parse/models/Song.dart';

class MusicData with ChangeNotifier {
  AudioPlayer audioPlayer;
  Song currentSong;
  bool repeat = false;
  bool mix = false;
  bool offlineMode = false;
  List<Song> playlist = [];
  List<Song> withoutMix = [];
  List<Song> localSongs = [];
  int currentIndexPlaylist = 0;

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
    _getState();
  }

  _getState() async {
    var repeated = await getPlayerState();
    if (repeated) {
      repeatClick();
    }
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

  setPlaylistSongs(List<Song> songList) {
    playlist = songList;
    notifyListeners();
  }

  loadSavedMusic() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
    localSongs = [];
    final fileList = Directory("$directory/songs/").listSync();
    fileList.forEach((songPath) {
      final song = formatSong(songPath.path);
      if (song != null) localSongs.add(song);
    });
  }

  mixClick() {
    mix = !mix;
    if (mix) {
      withoutMix = playlist;
      playlist..shuffle();
    } else {
      playlist = withoutMix;
    }
    currentIndexPlaylist = playlist.indexOf(currentSong);
    notifyListeners();
  }

  repeatClick() async {
    repeat = !repeat;
    if (repeat) {
      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
    savePlayerState(repeat);
    notifyListeners();
  }

  playlistAddClick() {
    notifyListeners();
  }

  loadPlaylist(List<Song> songList) {
    playlist = songList;
    notifyListeners();
  }

  playerPlay(Song song) async {
    audioPlayer.play(song.path);
    playerState = AudioPlayerState.PLAYING;
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
    if (currentIndexPlaylist > 0) --currentIndexPlaylist;
    playerPlay(playlist[currentIndexPlaylist]);
    notifyListeners();
  }

  next() {
    if (currentIndexPlaylist < playlist.length) ++currentIndexPlaylist;
    playerPlay(playlist[currentIndexPlaylist]);
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
