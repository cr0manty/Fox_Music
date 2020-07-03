import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/database.dart';
import 'package:fox_music/provider/shared_prefs.dart';
import 'package:fox_music/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/functions/format/song_name.dart';
import 'package:fox_music/models/song.dart';
import 'package:random_string/random_string.dart';
import 'package:audio_manager/audio_manager.dart';

enum PlayerState { PLAYING, STOP, BUFFERING }

class MusicData with ChangeNotifier {
  PlayerState playerState;
  Song _song;

  bool repeat = false;
  bool mix = false;

  bool isLocal = true;
  bool localUpdate = true;
  bool playlistUpdate = true;
  bool playlistPageUpdate = true;
  bool playlistListUpdate = true;

  List<Song> localSongs = [];
  List<Song> playlist = [];
  double volume = AudioManager.instance.volume;
  int selectedIndex;

  Duration songPosition;
  Duration songDuration;

  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerState;
  StreamSubscription _playerNotifyState;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;

  Stream<bool> get onPlayerActive => _playerActive.stream;

  Stream<bool> get onPlayerChangeState => _playerStateStream.stream;

  final StreamController<bool> _playerActive =
      StreamController<bool>.broadcast();

  final StreamController<bool> _playerStateStream =
      StreamController<bool>.broadcast();

  set currentSong(Song song) {
    _song = song;
    _playerActive.add(song != null);
  }

  get currentSong => _song;

  init() async {
    playerState = PlayerState.STOP;
    AudioManager.instance.nextMode(playMode: PlayMode.sequence);
    _initPlayer();
    loadSavedMusic();
    _getState();
  }

  void _initPlayer() {
    AudioManager.instance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          playerState = PlayerState.BUFFERING;
          _playerStateStream.add(null);
          notifyListeners();
          break;
        case AudioManagerEvents.ready:
          _playerStateStream.add(true);
          playerState = PlayerState.PLAYING;
          if (args['duration'] != null || args['_duration'] != null)
            songDuration =
                args['duration'] != null ? args['duration'] : args['_duration'];
          if (args['position']) songPosition = args['position'];
          _playerStateStream.add(true);
          notifyListeners();
          break;
        case AudioManagerEvents.playstatus:
          if (AudioManager.instance.isPlaying) {
            playerState = PlayerState.PLAYING;
          } else {
            playerState = PlayerState.STOP;
          }
          _playerStateStream.add(AudioManager.instance.isPlaying);
          notifyListeners();
          break;
        case AudioManagerEvents.timeupdate:
          songDuration = args["duration"];
          songPosition = args["position"];
          notifyListeners();
          break;
        case AudioManagerEvents.error:
          print('audioPlayer error : $args');
          currentSong = null;
          playerStop();
          songDuration = Duration(seconds: 0);
          songPosition = Duration(seconds: 0);
          notifyListeners();
          break;
        case AudioManagerEvents.ended:
          if (repeat) {
            repeatPlay();
          } else if (mix) {
            mixPlay();
          } else {
            next();
          }
          break;
        case AudioManagerEvents.next:
          next(change: false);
          break;
        case AudioManagerEvents.previous:
          prev(change: false);
          break;
        default:
          break;
      }
    });
  }

  void _getState() {
    var data = SharedPrefs.getPlayerState();
    if (data['repeat']) {
      repeatClick();
    }
  }

  void setPlaylistSongs(List<Song> songList, Song currentSong,
      {bool local = true}) {
    if (songList != playlist || local != isLocal) {
      isLocal = local;
      playlist = songList;
      List<AudioInfo> _list = [];
      int index = 0;
      songList.asMap()
        ..forEach((int index, Song song) {
          if (currentSong == song && local == isLocal) index = index;
          String url = local ? 'file://${song.path}' : song.download;
          String image = song.image != null && song.image.isNotEmpty
              ? song.image
              : 'https://pbs.twimg.com/profile_images/930254447090991110/K1MfcFXX.jpg';
          _list.add(AudioInfo(url,
              title: song.title, desc: song.artist, coverUrl: image));
        });
      AudioManager.instance.stop();
      AudioManager.instance.audioList = _list;

      notifyListeners();
    }
  }

  void renameSong(Song song) async {
    String newFileName = await formatFileName(song, localSongs.length + 1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = '$dir/songs/$newFileName';

    File oldSong = File(song.path);
    File newSong = File(path);

    var bytes = await oldSong.readAsBytes();
    await newSong.writeAsBytes(bytes);
    await oldSong.delete();

    song.path = path;
    notifyListeners();

    loadSavedMusic();
  }

  void loadSavedMusic() async {
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final documentDir = Directory("$directory/songs/");
    if (!documentDir.existsSync()) {
      documentDir.createSync();
    }
    final fileList = Directory("$directory/songs/").listSync();
    localSongs = [];

    fileList.forEach((songPath) async {
      final song = formatSong(songPath.path);
      if (song == null) {
        var rng = Random();
        Song song = Song(
            title: randomAlpha(15),
            path: songPath.path,
            duration: 200,
            artist: randomAlpha(15),
            song_id: rng.nextInt(100000));
        localSongs.add(song);
        renameSong(song);
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
    AudioManager.instance.seekTo(Duration(seconds: value));
    notifyListeners();
  }

  void updateVolume(double value) {
    AudioManager.instance.setVolume(value);
    volume = value;
    notifyListeners();
  }

  void mixClick({bool mixThis}) {
    mix = mixThis == null ? !mix : mixThis;
    notifyListeners();
  }

  void repeatClick() async {
    repeat = !repeat;
    notifyListeners();
    SharedPrefs.savePlayerState(repeat);
  }

  playPlaylist(Playlist thisPlaylist, {bool mix = false}) async {
    Playlist newPlaylist = await DBProvider.db.getPlaylist(thisPlaylist.id);
    List<String> songIdList = newPlaylist.splitSongList();
    List<Song> songList = await loadPlaylistTrack(songIdList);
    isLocal = true;
    playlist = songList;

    List<AudioInfo> _list = [];

    if (songList.length != 0) {
      if (currentSong != null && playerState == PlayerState.PLAYING) {
        await playerStop();
      }

      songList.forEach((Song song) {
        String image = song.image != null && song.image.isNotEmpty
            ? song.image
            : 'https://pbs.twimg.com/profile_images/930254447090991110/K1MfcFXX.jpg';
        _list.add(AudioInfo('file://${song.path}',
            title: song.title, desc: song.artist, coverUrl: image));
      });
      AudioManager.instance.audioList = _list;

      if (mix) mixClick(mixThis: true);
      playerPlay();
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

    List<AudioInfo> _list = [];

    songList.forEach((Song song) {
      String image = song.image != null && song.image.isNotEmpty
          ? song.image
          : DEFAULT_PLAYER_IMAGE_URL;
      _list.add(AudioInfo('file:/${song.path}',
          title: song.title, desc: song.artist, coverUrl: image));
    });
    AudioManager.instance.audioList = _list;
    notifyListeners();
  }

  void deleteSong(Song song) {
    playlist.remove(song);

    if (currentSong == song) {
      if (playerState == PlayerState.PLAYING) {
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

  void playerPlay({int index = 0, Song song}) async {
    volume = AudioManager.instance.volume;
    if (AudioManager.instance.isPlaying) return;

    if ((AudioManager.instance.audioList.length < index || index == -1) &&
        song != null) {
      String url = song.path != null && song.path.isNotEmpty
          ? 'file://${song.path}'
          : song.download;

      songDuration = Duration(seconds: song.duration ?? 0);
      songPosition = Duration(seconds: 0);
      selectedIndex = index;
      currentSong = song;
      _playerStateStream.add(true);
      notifyListeners();

      AudioManager.instance
          .start(url, song.title, desc: song.artist, auto: true);
    } else if (AudioManager.instance.audioList.length > index) {
      selectedIndex = index;
      currentSong = playlist[index];
      songDuration = Duration(seconds: currentSong.duration ?? 0);
      songPosition = Duration(seconds: 0);
      _playerStateStream.add(true);
      notifyListeners();

      AudioManager.instance.play(index: index, auto: true);
    }
  }

  void playerStop() async {
    playerState = PlayerState.STOP;
    currentSong = null;
    _playerStateStream.add(false);
    notifyListeners();

    AudioManager.instance.stop();
  }

  void playerResume() {
    playerState = PlayerState.PLAYING;
    _playerStateStream.add(true);
    notifyListeners();

    AudioManager.instance.toPlay();
  }

  void playerPause() async {
    playerState = PlayerState.STOP;
    _playerStateStream.add(false);
    notifyListeners();

    AudioManager.instance.toPause();
  }

  void prev({bool change = true}) async {
    if (change) AudioManager.instance.previous();

    selectedIndex = AudioManager.instance.curIndex;
    currentSong = playlist[selectedIndex];
    songDuration = Duration(seconds: currentSong.duration ?? 0);
    songPosition = Duration(seconds: 0);
    _playerStateStream.add(true);
    notifyListeners();
  }

  void next({bool change = true}) async {
    if (playerState == PlayerState.BUFFERING) return;

    if (!mix) {
      if (change) AudioManager.instance.next();

      selectedIndex = AudioManager.instance.curIndex;
      currentSong = playlist[selectedIndex];
      songDuration = Duration(seconds: currentSong.duration ?? 0);
      songPosition = Duration(seconds: 0);
      _playerStateStream.add(true);
      notifyListeners();
    } else {
      mixPlay();
    }
  }

  void repeatPlay() async {
    notifyListeners();
    AudioManager.instance.seekTo(Duration(seconds: 0));
    AudioManager.instance.playOrPause();
  }

  void mixPlay() {
    Random rnd = Random();
    selectedIndex = rnd.nextInt(AudioManager.instance.audioList.length);

    currentSong = playlist[selectedIndex];
    songDuration = Duration(seconds: currentSong.duration ?? 0);
    songPosition = Duration(seconds: 0);
    _playerStateStream.add(true);
    songPosition = Duration(seconds: 0);
    notifyListeners();

    AudioManager.instance.play(index: selectedIndex, auto: true);
  }

  bool isPlaying(int songId) {
    return currentSong != null && currentSong.song_id == songId;
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _playerState?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerNotifyState?.cancel();
    _playerActive?.close();
    _playerStateStream?.close();
    super.dispose();
  }
}
