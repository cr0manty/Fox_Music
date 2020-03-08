import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/functions/utils/rename_song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/functions/format/song_name.dart';
import 'package:fox_music/functions/get/player_state.dart';
import 'package:fox_music/functions/save/player_state.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/utils/database.dart';
import 'package:media_metadata_plugin/media_metadata_plugin.dart';
import 'package:random_string/random_string.dart';

class MusicData with ChangeNotifier {
  AudioPlayer audioPlayer;
  Song currentSong;
  bool repeat = false;
  bool mix = false;
  bool initCC = false;
  List<Song> withoutMix = [];
  List<Song> playlist = [];
  List<Song> localSongs = [];
  int currentIndexPlaylist = 0;
  double volume = 1;

  Duration songPosition;
  Duration songDuration;
  var platform;

  AudioPlayerState playerState;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerError;
  StreamSubscription _playerState;
  StreamSubscription _playerNotifyState;

  init(thisPlatform) async {
    platform = thisPlatform;
    await initPlayer();
    await loadSavedMusic();
  }

  initPlayer() {
    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
    playerState = audioPlayer.state;

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
      if (initCC) {
        setCCData(duration);
        initCC = false;
      }
      notifyListeners();
    });
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      songPosition = p;
      notifyListeners();
    });
    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      if (!repeat) {
        next();
        initCC = true;
      }
      notifyListeners();
    });

    _playerError = audioPlayer.onPlayerError.listen((error) {
      print(error);
    });

    _playerState = audioPlayer.onPlayerStateChanged.listen((state) {
      playerState = state;
      notifyListeners();
    });

    _playerNotifyState =
        audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      playerState = state;
      notifyListeners();
    });
    _getState();
  }

  _getState() async {
    var data = await getPlayerState();
    if (data['repeat']) {
      repeatClick();
    }
    updateVolume(data['volume']);
  }

  setCCData(Duration duration) {
    if (platform == TargetPlatform.iOS) {
      audioPlayer.startHeadlessService();

      audioPlayer.setNotification(
          title: currentSong.title,
          artist: currentSong.artist,
          imageUrl:
              'https://pbs.twimg.com/profile_images/930254447090991110/K1MfcFXX.jpg',
          forwardSkipInterval: const Duration(seconds: 5),
          backwardSkipInterval: const Duration(seconds: 5),
          duration: duration);
    }
  }

  setPlaylistSongs(List<Song> songList, Song song) {
    if (songList != playlist) {
      playlist.clear();
      playlist.addAll(songList);
      if (mix) mixClick();

      currentIndexPlaylist = playlist.indexOf(song);
      notifyListeners();
    }
  }

  void loadLocalDBSongs() async {
    localSongs = [];
    localSongs = await DBProvider.db.getAllSong();
  }

  bool _filterSongs(String artist, String title) {
    return localSongs
            .where((song) =>
                song.artist.toLowerCase().contains(artist.toLowerCase()) &&
                song.title.toLowerCase().contains(title.toLowerCase()))
            .toList()
            .length >
        0;
  }

  void loadSavedMusic() async {
    await loadLocalDBSongs();
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
    final fileList = Directory("$directory/songs/").listSync();
    fileList.forEach((songPath) async {
      final song = formatSong(songPath.path);
      if (song == null) {
        var songData =
            await MediaMetadataPlugin.getMediaMetaData(songPath.path);
        if (_filterSongs(
            songData.artistName ?? '', songData.artistName ?? '')) {
          var rng = new Random();
          Song song = Song(
              title: songData.trackName.isNotEmpty
                  ? songData.trackName
                  : randomAlpha(15),
              path: songPath.path,
              duration: songData.trackDuration,
              artist:
                  songData.artistName != null && songData.artistName.isNotEmpty
                      ? songData.artistName
                      : randomAlpha(15),
              song_id: rng.nextInt(100000));
          DBProvider.db.newSong(song);
          localSongs.add(song);
          renameSong(song);
        }
      } else if (localSongs.indexOf(song) == -1 && song != null) {
        localSongs.add(song);
      }
    });
  }

  void updateVolume(double value) {
    audioPlayer.setVolume(value);
    volume = value;
    notifyListeners();
    savePlayerState(repeat, volume);
  }

  mixClick() {
    mix = !mix;
    if (mix) {
      withoutMix = playlist;
      playlist..shuffle();
      playlist.remove(currentSong);
      playlist.insert(0, currentSong);
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

    savePlayerState(repeat, volume);
    notifyListeners();
  }

  playlistAddClick() {
    notifyListeners();
  }

  loadPlaylist(List<Song> songList) {
    playlist = songList;
    notifyListeners();
  }

  bool sliderValue() {
    return songDuration != null && songPosition != null;
  }

  void playerPlay(Song song, {isLocal = true}) async {
    await audioPlayer.play(song.path, isLocal: isLocal);
    playerState = AudioPlayerState.PLAYING;
    currentSong = song;
    initCC = true;
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
    if (currentIndexPlaylist > 0)
      --currentIndexPlaylist;
    else
      currentIndexPlaylist = playlist.length - 1;
    playerPlay(playlist[currentIndexPlaylist]);
    notifyListeners();
  }

  next() {
    if (currentIndexPlaylist < playlist.length - 1)
      ++currentIndexPlaylist;
    else
      currentIndexPlaylist = 0;
    playerPlay(playlist[currentIndexPlaylist]);
    notifyListeners();
  }

  bool isPlaying(int songId) {
    return currentSong != null && currentSong.song_id == songId;
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
    _playerError?.cancel();
    _playerState?.cancel();
    _playerNotifyState?.cancel();
    super.dispose();
  }
}
