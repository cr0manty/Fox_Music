import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/instances/api.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/instances/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/instances/account_data.dart';

import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/instances/download_data.dart';
import 'package:fox_music/ui/main_tab.dart';
import 'package:fox_music/utils/utils.dart';
import 'package:package_info/package_info.dart';

import 'instances/key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SharedPrefs.getInstance() == null) {
    await SharedPrefs.init();
  }

  await ConnectionsCheck.instance.initialise();
  await AccountData.instance.init();

  MusicData musicData = MusicData();
  MusicDownloadData downloadData = MusicDownloadData();

  await musicData.init();
  await downloadData.init(musicData);

  runApp(FoxMusic(
    musicData: musicData,
    downloadData: downloadData,
  ));
}

class FoxMusic extends StatefulWidget {
  final MusicData musicData;
  final MusicDownloadData downloadData;

  FoxMusic({this.downloadData, this.musicData});

  @override
  FoxMusicState createState() => FoxMusicState();
}

class FoxMusicState extends State<FoxMusic> {
  @override
  void initState() {
    super.initState();
    ConnectionsCheck.instance.onChange.listen((event) => setState(() {}));
    AccountData.instance.onUserChangeAccount.listen((event) => setState(() {}));
  }

  void _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentAppVersion;

    if (ConnectionsCheck.instance.isOnline) {
      currentAppVersion = await Api.appVersionGet();
      if (currentAppVersion != null)
        SharedPrefs.saveLastVersion(currentAppVersion);
    } else {
      currentAppVersion = SharedPrefs.getLastVersion();
    }
    if (currentAppVersion != null &&
        packageInfo.version != currentAppVersion['version']) {
      await Utils.pickDialog(context, 'New version available',
          currentAppVersion['update_details'], currentAppVersion['url']);
    }
  }

  Widget _checkVersionAndContinue() {
//    _checkVersion();
    return MainPage(
        musicData: widget.musicData, downloadData: widget.downloadData);
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
        home: _checkVersionAndContinue());
  }

  @override
  void dispose() {
    ConnectionsCheck.instance.dispose();
    AccountData.instance.dispose();
    super.dispose();
  }
}
