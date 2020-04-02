import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/functions/format/song_name.dart';
import 'package:fox_music/functions/get/player_state.dart';
import 'package:fox_music/functions/save/player_state.dart';
import 'package:fox_music/models/song.dart';
import 'package:media_metadata_plugin/media_metadata_plugin.dart';
import 'package:random_string/random_string.dart';

class MusicData with ChangeNotifier {
  AudioPlayer audioPlayer;
  Song _song;

  Map songData;
  bool repeat = false;
  bool mix = false;

  bool initCC = false;
  bool isLocal = true;
  bool localUpdate = true;
  bool playlistUpdate = true;
  bool playlistPageUpdate = true;
  bool playlistListUpdate = true;

  List<Song> withoutMix = [];
  List<Song> playlist = [];
  List<Song> localSongs = [];
  int currentIndexPlaylist = 0;
  double volume = 1;
  TargetPlatform platform;

  Duration songPosition;
  Duration songDuration;
  AudioPlayerState playerState;

  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerState;
  StreamSubscription _playerNotifyState;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;

  Stream<bool> get onPlayerActive => _playerActive.stream;

  final StreamController<bool> _playerActive =
      StreamController<bool>.broadcast();

  set currentSong(Song song) {
    _song = song;
    _playerActive.add(song != null);
  }

  get currentSong => _song;

  init(thisPlatform) async {
    platform = thisPlatform;
    await initPlayer();
    await loadSavedMusic();
    await _getState();
  }

  void initPlayer() {
    audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
    playerState = audioPlayer.state;

    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      if (!repeat) {
        next();
      } else {
        playerPlay(currentSong);
      }
      audioPlayer.setVolume(volume);
      initCC = true;
      notifyListeners();
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

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
      if (currentSong?.duration != duration.inSeconds &&
          currentSong?.path != null) {
        currentSong.duration = duration.inSeconds;
      }
      if (initCC) {
        setCCData(duration);
        initCC = false;
      }
    });
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      songPosition = p;
      notifyListeners();
    });
    audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      currentSong = null;
      playerStop();
      songDuration = Duration(seconds: 0);
      songPosition = Duration(seconds: 0);
      notifyListeners();
    });
    songData = {'title': '', 'artist': ''};
  }

  void _getState() async {
    var data = await getPlayerState();
    if (data['repeat']) {
      repeatClick();
    } else {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
  }

  void setCCData(Duration duration) {
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

  void setPlaylistSongs(List<Song> songList, Song song, {bool local = true}) {
    isLocal = local;
    if (songList != playlist) {
      playlist.clear();
      playlist.addAll(songList);
      if (mix) mixClick();

      currentIndexPlaylist = playlist.indexOf(song);
      notifyListeners();
    }
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

  void renameSong(Song song) async {
    String newFileName = await formatFileName(song);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = '$dir/songs/$newFileName';

    File oldSong = File(song.path);
    File newSong = new File(path);

    var bytes = await oldSong.readAsBytes();
    await newSong.writeAsBytes(bytes);
    await oldSong.delete();

    song.path = path;
    notifyListeners();

    loadSavedMusic();
  }

  void loadSavedMusic() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = new Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
    final fileList = Directory("$directory/songs/").listSync();
    localSongs = [];

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
          localSongs.add(song);
          renameSong(song);
        }
      } else if (song != null && localSongs.indexOf(song) == -1) {
        localSongs.add(song);
      }
    });
    notifyListeners();
  }

  void seek({duration}) {
    int value = (duration != null && duration < 1
            ? durToInt(songDuration) * duration
            : 0)
        .toInt();
    audioPlayer.seek(Duration(seconds: value));
    notifyListeners();
  }

  void updateVolume(double value) {
    audioPlayer.setVolume(value);
    volume = value;
    notifyListeners();
  }

  void mixClick({bool mixThis}) {
    mix = mixThis == null ? !mix : mixThis;
    if (mix) {
      withoutMix = playlist;
      playlist..shuffle();
      if (currentSong != null) {
        playlist.remove(currentSong);
        playlist.insert(0, currentSong);
      }
    } else {
      playlist = withoutMix;
    }
    currentIndexPlaylist =
        currentSong != null ? playlist.indexOf(currentSong) : 0;
    notifyListeners();
  }

  void repeatClick() async {
    repeat = !repeat;
    notifyListeners();
    savePlayerState(repeat);
  }

  playPlaylist(Playlist thisPlaylist, {bool mix = false}) async {
    Playlist newPlaylist = await DBProvider.db.getPlaylist(thisPlaylist.id);
    List<String> songIdList = newPlaylist.splitSongList();
    List<Song> songList = await loadPlaylistTrack(songIdList);
    isLocal = true;
    playlist = songList;

    if (songList.length != 0) {
      if (currentSong != null && playerState == AudioPlayerState.PLAYING) {
        await playerStop();
      }
      if (mix) mixClick(mixThis: true);

      await playerPlay(playlist[0]);
    }
  }

  loadPlaylistTrack(List<String> songsListId) async {
    List<Song> songList = [];

    await Future.wait(localSongs.map((Song song) async {
      if (songsListId.contains(song.song_id.toString())) songList.add(song);
    }));
    return songList;
  }

  loadPlaylistAddTrack(List<String> songsListId) async {
    List<Song> songList = [];

    localSongs.forEach((Song song) {
      song.inPlaylist = songsListId.contains(song.song_id.toString());
      songList.add(song);
    });
    return songList;
  }

  void loadPlaylist(List<Song> songList) {
    playlist = songList;
    notifyListeners();
  }

  void _stopAllPlayers() {
    var players = AudioPlayer.players;

    players.forEach((key, player) async {
      await player.stop();
    });
  }

  void deleteSong(Song song) {
    playlist.remove(song);

    if (currentSong == song) {
      if (playerState == AudioPlayerState.PLAYING) {
        if (playlist.length == 0) {
          currentSong = null;
          playerStop();
        } else {
          playlist.remove(song);
          next();
        }
      } else {
        currentSong = null;
      }
    } else {
      playlist.remove(song);
      notifyListeners();
    }
  }

  void playerPlay(Song song) async {
    audioPlayer.release();
    if (!isLocal && song.download.isNotEmpty) {
      await _stopAllPlayers();
      await audioPlayer.play(song.download, isLocal: isLocal);
    } else if (isLocal) {
      await _stopAllPlayers();
      await audioPlayer.play(song.path, isLocal: isLocal);
    } else {
      playerPause();
      return;
    }
    playerState = AudioPlayerState.PLAYING;
    currentSong = song;
    songData = {'title': currentSong.title, 'artist': currentSong.artist};

    initCC = true;
    notifyListeners();
  }

  void playerStop() async {
    audioPlayer.stop();
    audioPlayer.release();
    playerState = AudioPlayerState.STOPPED;
    currentSong = null;
    notifyListeners();
  }

  void playerResume() async {
    audioPlayer.resume();
    playerState = AudioPlayerState.PLAYING;
    notifyListeners();
  }

  void playerPause() async {
    audioPlayer.pause();
    playerState = AudioPlayerState.PAUSED;
    notifyListeners();
  }

  void prev() {
    if (currentIndexPlaylist > 0)
      --currentIndexPlaylist;
    else
      currentIndexPlaylist = playlist.length - 1;
    playerPlay(playlist[currentIndexPlaylist]);
    notifyListeners();
  }

  void next() {
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

  @override
  void dispose() {
    audioPlayer?.stop();
    _playerCompleteSubscription?.cancel();
    _playerState?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerNotifyState?.cancel();
    audioPlayer?.release();
    _playerActive?.close();
    super.dispose();
  }
}
