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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SharedPrefs.getInstance() == null) {
    await SharedPrefs.init();
  }

  await ConnectionsCheck.instance.initialise();
  await AccountData.instance.init();
  await MusicData.instance.init();
  MusicDownloadData.instance.init();
  Utils.instance.init();

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

  @override
  void initState() {
    super.initState();
    _connectionsCheck =
        ConnectionsCheck.instance.onChange.listen((event) => setState(() {}));
    _accountData = AccountData.instance.onUserChangeAccount
        .listen((event) => setState(() {}));
    _musicData =
        MusicData.instance.notifyStream.listen((event) =>
            setState(() {
              Utils.instance.playerUsing =
                  MusicData.instance.currentSong != null;
            }));
    _musicDownloadData = MusicDownloadData.instance.notifyStream
        .listen((event) => setState(() {}));
  }


  Widget _checkVersionAndContinue(BuildContext context) {
//    _checkVersion();
    return MainPage();
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
        home: _checkVersionAndContinue(context));
  }

  @override
  void dispose() {
    ConnectionsCheck.instance.dispose();
    AccountData.instance.dispose();
    MusicData.instance.dispose();
    MusicDownloadData.instance.dispose();

    _connectionsCheck?.cancel();
    _accountData?.cancel();
    _musicData?.cancel();
    _musicDownloadData?.cancel();
    super.dispose();
  }
}
