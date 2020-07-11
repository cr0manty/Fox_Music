import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/instances/database.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/utils/constants.dart';
import 'package:fox_music/utils/help_tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fox_music/models/song.dart';
import 'package:random_string/random_string.dart';
import 'package:audio_manager/audio_manager.dart';

enum PlayerState { PLAYING, STOP, BUFFERING }

class MusicData {
  MusicData._internal();

  PlayerState playerState;
  Song _song;

  bool repeat = false;
  bool mix = false;

  bool isLocal = true;
  bool _localUpdate = true;
  bool playlistUpdate = true;
  bool playlistPageUpdate = true;

  set localUpdate(bool update) {
    _localUpdate = update;
    _playerStream.add(update);
    _notifyStream.add(update);
  }

  bool get localUpdate => _localUpdate;

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

  Stream<bool> get notifyStream => _notifyStream.stream;

  Stream<bool> get playerStream => _playerStream.stream;

  Stream<bool> get filesystemStream => _filesystemStream.stream;

  Stream<bool> get songUpdates => _songUpdates.stream;

  final StreamController<bool> _playerActive =
      StreamController<bool>.broadcast();
  final StreamController<bool> _filesystemStream =
      StreamController<bool>.broadcast();
  final StreamController<bool> _notifyStream =
      StreamController<bool>.broadcast();
  final StreamController<bool> _songUpdates =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playerStream =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playerStateStream =
      StreamController<bool>.broadcast();

  set currentSong(Song song) {
    _song = song;
    _playerActive.add(song != null);
  }

  get currentSong => _song;

  static final MusicData _instance = MusicData._internal();

  static MusicData get instance => _instance;

  init() async {
    playerState = PlayerState.STOP;
//    AudioManager.instance.nextMode(playMode: PlayMode.);
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
          break;
        case AudioManagerEvents.ready:
          playerState = PlayerState.PLAYING;
          if (args['duration'] != null || args['_duration'] != null)
            songDuration =
                args['duration'] != null ? args['duration'] : args['_duration'];
          if (args['position']) songPosition = args['position'];
          _playerStateStream.add(true);
          break;
        case AudioManagerEvents.playstatus:
          if (AudioManager.instance.isPlaying) {
            playerState = PlayerState.PLAYING;
          } else {
            playerState = PlayerState.STOP;
          }
          _playerStateStream.add(AudioManager.instance.isPlaying);
          break;
        case AudioManagerEvents.timeupdate:
          songDuration = args["duration"];
          songPosition = args["position"];
          _playerStream.add(true);
          break;
        case AudioManagerEvents.error:
          print('audioPlayer error : $args');
          currentSong = null;
          playerStop();
          songDuration = Duration(seconds: 0);
          songPosition = Duration(seconds: 0);
          _notifyStream.add(true);
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
      songList.asMap()
        ..forEach((int index, Song song) {
          if (currentSong == song && local == isLocal) index = index;
          String url = local ? 'file://${song.path}' : song.download;
          String image = song.image != null && song.image.isNotEmpty
              ? song.image
              : PLAYER_DEFAULT;
          _list.add(AudioInfo(url,
              title: song.title, desc: song.artist, coverUrl: image));
        });
      AudioManager.instance.stop();
      AudioManager.instance.audioList = _list;
    }
  }

  void renameSong(Song song) async {
    String newFileName = song.formatFileName(localSongs.length + 1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = '$dir/songs/$newFileName';

    File oldSong = File(song.path);
    File newSong = File(path);

    var bytes = await oldSong.readAsBytes();
    await newSong.writeAsBytes(bytes);
    await oldSong.delete();

    song.path = path;
    _filesystemStream.add(true);

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
      final song = Song.formatSong(songPath.path);
      if (song == null) {
        var rng = Random();
        Song song = Song(
            title: randomAlpha(15),
            path: songPath.path,
            duration: 200,
            artist: randomAlpha(15),
            songId: rng.nextInt(100000));
        localSongs.add(song);
        renameSong(song);
      } else if (song != null && localSongs.indexOf(song) == -1) {
        localSongs.add(song);
      }
    });
    _filesystemStream.add(true);
  }

  void seek({duration}) {
    int value = (duration != null && duration < 1
            ? HelpTools.durToInt(songDuration) * duration
            : 0)
        .toInt();
    AudioManager.instance.seekTo(Duration(seconds: value));
    _playerStream.add(true);
  }

  void updateVolume(double value) {
    AudioManager.instance.setVolume(value);
    volume = value;
    _playerStream.add(true);
  }

  void mixClick({bool mixThis}) {
    mix = mixThis == null ? !mix : mixThis;
    _playerStream.add(true);
  }

  void repeatClick() async {
    repeat = !repeat;
    _playerStream.add(true);
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
            : PLAYER_DEFAULT;
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
      if (songsListId.contains(song.songId.toString())) songList.add(song);
    }));
    return songList;
  }

  loadPlaylistAddTrack(List<String> songsListId) async {
    List<Song> songList = [];

    localSongs.forEach((Song song) {
      song.inPlaylist = songsListId.contains(song.songId.toString());
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
    }
    _filesystemStream.add(true);
  }

  void playerPlay({int index = 0, Song song}) async {
    volume = AudioManager.instance.volume;
    if (AudioManager.instance.isPlaying) AudioManager.instance.stop();

    if ((AudioManager.instance.audioList.length < index || index == -1) &&
        song != null) {
      String url = song.path != null && song.path.isNotEmpty
          ? 'file://${song.path}'
          : song.download;

      songDuration = Duration(seconds: song.duration ?? 0);
      songPosition = Duration(seconds: 0);
      selectedIndex = index;
      currentSong = song;
      _notifyStream.add(true);
      _playerStateStream.add(true);

      AudioManager.instance
          .start(url, song.title, desc: song.artist, auto: true);
    } else if (AudioManager.instance.audioList.length > index) {
      selectedIndex = index;
      currentSong = playlist[index];
      _notifyStream.add(true);
      songDuration = Duration(seconds: currentSong.duration ?? 0);
      songPosition = Duration(seconds: 0);
      _playerStateStream.add(true);

      AudioManager.instance.play(index: index, auto: true);
    }
  }

  void playerStop() async {
    playerState = PlayerState.STOP;
    currentSong = null;
    _notifyStream.add(true);
    songPosition = Duration(seconds: 0);
    _playerStateStream.add(false);

    AudioManager.instance.stop();
  }

  void updateFileSystem() {
    _filesystemStream.add(true);
  }

  void playerResume() {
    _notifyStream.add(true);
    playerState = PlayerState.PLAYING;
    _playerStateStream.add(true);
    AudioManager.instance.toPlay();
  }

  void playerPause() async {
    _notifyStream.add(true);
    playerState = PlayerState.STOP;
    _playerStateStream.add(false);
    AudioManager.instance.toPause();
  }

  void prev({bool change = true}) async {
    if (change) AudioManager.instance.previous();

    selectedIndex = AudioManager.instance.curIndex;
    currentSong = playlist[selectedIndex];
    _notifyStream.add(true);
    songDuration = Duration(seconds: currentSong.duration ?? 0);
    songPosition = Duration(seconds: 0);
    _playerStateStream.add(true);
  }

  void next({bool change = true}) async {
    if (playerState == PlayerState.BUFFERING) {
      Future.delayed(Duration(seconds: 1), () {
        next(change: change);
      });
    } else {
      if (!mix) {
        selectedIndex = AudioManager.instance.curIndex + 1;
        currentSong = playlist[selectedIndex];
        _notifyStream.add(true);
        _playerStateStream.add(true);
        songDuration = Duration(seconds: currentSong.duration ?? 0);
        songPosition = Duration(seconds: 0);
        if (change) AudioManager.instance.next();
      } else {
        mixPlay();
      }
    }
  }

  void repeatPlay() async {
    _notifyStream.add(true);
    AudioManager.instance.seekTo(Duration(seconds: 0));
    AudioManager.instance.playOrPause();
  }

  void mixPlay() {
    Random rnd = Random();
    selectedIndex = rnd.nextInt(AudioManager.instance.audioList.length);

    currentSong = playlist[selectedIndex];
    _notifyStream.add(true);
    songDuration = Duration(seconds: currentSong.duration ?? 0);
    songPosition = Duration(seconds: 0);
    _playerStateStream.add(true);
    songPosition = Duration(seconds: 0);

    AudioManager.instance.play(index: selectedIndex, auto: true);
  }

  bool isPlaying(int songId) {
    return currentSong != null && currentSong.songId == songId;
  }

  void saveSharedSong(String songPath) async {
    File file = File(songPath);

    if (!await file.exists()) {
      return;
    }

    Song song = Song(
      title: randomAlpha(15),
      path: songPath,
      duration: 200,
      artist: randomAlpha(15),
      songId: Random().nextInt(100000),
    );

    String newFileName = song.formatFileName(song.songId);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = '$dir/songs/$newFileName';

    File newSong = File(path);

    var bytes = await file.readAsBytes();
    await newSong.writeAsBytes(bytes);
    await file.delete();

    song.path = path;
    localSongs.add(song);
    _songUpdates.add(true);
  }

  void dispose() {
    _playerCompleteSubscription?.cancel();
    _playerState?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerNotifyState?.cancel();

    _playerActive?.close();
    _playerStateStream?.close();
    _notifyStream?.close();
    _playerStream?.close();
    _filesystemStream?.close();
    _songUpdates?.close();
  }
}
