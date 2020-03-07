import 'dart:io';
import 'dart:math';
import 'package:audiofileplayer/audio_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/functions/utils/rename_song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/functions/format/song_name.dart';
import 'package:fox_music/functions/get/player_state.dart';
import 'package:fox_music/functions/save/player_state.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/utils/database.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:media_metadata_plugin/media_metadata_plugin.dart';
import 'package:random_string/random_string.dart';

enum PlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  COMPLETED,
}

class MusicData with ChangeNotifier {
  Audio currentAudio;
  Song currentSong;
  bool repeat = false;
  bool mix = false;
  bool initCC = false;
  List<Song> withoutMix = [];
  List<Song> playlist = [];
  List<Song> localSongs = [];
  int currentIndexPlaylist = 0;
  double volumeValue = 1;

  double songPosition;
  double songDuration;
  var platform;

  PlayerState playerState = PlayerState.STOPPED;

  init(thisPlatform) async {
    platform = thisPlatform;
    await _getState();
    await loadSavedMusic();
  }

//  initPlayer() {
//    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
//
//    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
//      songDuration = duration;
//      if (initCC) {
//        setCCData(duration);
//        initCC = false;
//      }
//      notifyListeners();
//    });
//    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
//      songPosition = p;
//      notifyListeners();
//    });
//    _playerCompleteSubscription =
//        audioPlayer.onPlayerCompletion.listen((event) {
//      if (!repeat) {
//        next();
//        initCC = true;
//      }
//      notifyListeners();
//    });
//
//    _playerError = audioPlayer.onPlayerError.listen((error) {
//      print(error);
//    });
//
//    _playerState = audioPlayer.onPlayerStateChanged.listen((state) {
//      audioPlayerState = state;
//      notifyListeners();
//    });
//
//    _playerNotifyState =
//        audioPlayer.onNotificationPlayerStateChanged.listen((state) {
//      audioPlayerState = state;
//      notifyListeners();
//    });
//    _getState();
//  }

  _getState() async {
    var data = await getPlayerState();
    if (data['repeat']) {
      repeatClick();
    }
    if (data['mix']) {
      mixClick();
    }
  }

//  setCCData(Duration duration) {
//    if (platform == TargetPlatform.iOS) {
//      audioPlayer.startHeadlessService();
//
//      audioPlayer.setNotification(
//          title: currentSong.title,
//          artist: currentSong.artist,
//          imageUrl:
//              'https://pbs.twimg.com/profile_images/930254447090991110/K1MfcFXX.jpg',
//          forwardSkipInterval: const Duration(seconds: 5),
//          backwardSkipInterval: const Duration(seconds: 5),
//          duration: duration);
//    }
//  }

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
    currentAudio.setVolume(value);
    volumeValue = currentAudio.volume;
    notifyListeners();
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

    savePlayerState(repeat, mix);
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

  Audio _preStartPlay(Function func, data) {
    return func(data, playInBackground: true, onPosition: (position) {
      songPosition = position;
      notifyListeners();
    }, onDuration: (duration) {
      songDuration = duration;
      notifyListeners();
    }, onComplete: () {
      if (!repeat) {
        currentAudio.dispose();
        next();
      } else {
        currentAudio.seek(0).then((value) {
          currentAudio.play();
        });
      }
      notifyListeners();
    });
  }

  playerPlay(Song song, {bool isLocal = true}) async {
    Function func = Audio.loadFromByteData;
    var data;

    if (currentAudio != null)
      currentAudio
        ..pause()
        ..dispose();

    if (isLocal) {
      File file = File(song.path);
      var bytes = await file.readAsBytes();
      data = ByteData.view(bytes.buffer);
    } else {
      func = Audio.loadFromRemoteUrl;
      data = song.download;
    }
    currentAudio = _preStartPlay(func, data);

    if (volumeValue != null) currentAudio.setVolume(volumeValue);
    volumeValue = currentAudio.volume;

    currentAudio.play();
    playerState = PlayerState.PLAYING;
    currentSong = song;
    _loadCCcontrol();
    notifyListeners();
  }

  _loadCCcontrol() {
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: currentSong.title,
        artist: currentSong.artist,
        durationSeconds: songDuration));

    AudioSystem.instance
        .setPlaybackState(true, songPosition);

    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.pause,
      AndroidMediaButtonType.stop,

    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
      MediaActionType.skipForward,
      MediaActionType.skipBackward,
      MediaActionType.seekTo,
    }, skipIntervalSeconds: 30);
  }

  playerStop() async {
    if (currentAudio != null) {
      currentAudio
        ..pause()
        ..dispose();
    }
    playerState = PlayerState.STOPPED;
    notifyListeners();
  }

  playerResume() async {
    if (currentAudio != null) {
      currentAudio.resume();
    }
    playerState = PlayerState.PLAYING;
    notifyListeners();
  }

  playerPause() async {
    if (currentAudio != null) {
      currentAudio.pause();
    }
    playerState = PlayerState.PAUSED;
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
      double value =
          (duration != null && duration < 1 ? songDuration * duration : 0);
      currentAudio.seek(value);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (currentAudio != null) {
      currentAudio
        ..pause()
        ..dispose();
    }
    super.dispose();
  }
}
