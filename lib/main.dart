import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/instances/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/instances/account_data.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/instances/download_data.dart';
import 'package:fox_music/ui/main_tab.dart';
import 'instances/key.dart';
import 'instances/utils.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;

  if (SharedPrefs.getInstance() == null) {
    await SharedPrefs.init();
  }

  await ConnectionsCheck.instance.initialise();
  await AccountData.instance.init();
  MusicData.instance.init();
  MusicDownloadData.instance.init();
  Utils.instance.init();

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(FoxMusic());
}

class FoxMusic extends StatefulWidget {
  @override
  FoxMusicState createState() => FoxMusicState();
}

class FoxMusicState extends State<FoxMusic> {
  StreamSubscription _connectionsCheck;
  StreamSubscription _accountData;
  StreamSubscription _musicData;
  StreamSubscription _musicDownloadData;
  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _connectionsCheck =
        ConnectionsCheck.instance.onChange.listen((event) => setState(() {}));

    _accountData = AccountData.instance.onUserChangeAccount
        .listen((event) => setState(() {}));

    _musicData = MusicData.instance.notifyStream.listen((event) => setState(() {
          Utils.instance.playerUsing = MusicData.instance.currentSong != null;
        }));

    _musicDownloadData = MusicDownloadData.instance.notifyStream
        .listen((event) => setState(() {}));

    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) async {
      if (value == null) return;

      await Future.wait(value.map((SharedMediaFile element) async {
        if (element.path.endsWith('.mp3')) {
          MusicData.instance.saveSharedSong(element.path);
        }
      }));
      print('Get file(inMemory) ${MusicData.instance.localSongs.length}');
    });

    ReceiveSharingIntent.getInitialMedia()
        .then((List<SharedMediaFile> value) async {
      if (value == null) return;
      await Future.wait(value.map((SharedMediaFile element) async {
        if (element.path.endsWith('.mp3')) {
          MusicData.instance.saveSharedSong(element.path);
        }
      }));
      print('Get file(closed) ${MusicData.instance.localSongs.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return CupertinoApp(
        navigatorKey: KeyHolder().key,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
            primaryColor: Color.fromRGBO(193, 39, 45, 1),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: HexColor.background()),
        home: MainPage());
  }

  @override
  void dispose() {
    ConnectionsCheck.instance?.dispose();
    AccountData.instance?.dispose();
    MusicData.instance?.dispose();
    MusicDownloadData.instance?.dispose();

    _connectionsCheck?.cancel();
    _accountData?.cancel();
    _musicData?.cancel();
    _musicDownloadData?.cancel();
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }
}
