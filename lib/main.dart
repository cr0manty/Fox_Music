import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/provider/api.dart';
import 'package:fox_music/provider/shared_prefs.dart';
import 'package:fox_music/utils/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:package_info/package_info.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/provider/account_data.dart';

import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/main_tab.dart';
import 'functions/utils/info_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ConnectionsCheck connection = ConnectionsCheck.instance;
  await connection.initialise();

  if (SharedPrefs.getInstance() == null) {
    await SharedPrefs.init();
  }

  MusicData musicData = new MusicData();
  AccountData accountData = new AccountData();
  MusicDownloadData downloadData = new MusicDownloadData();

  await musicData.init();
  await accountData.init(connection.isOnline);
  await downloadData.init(musicData, connection.isOnline);

  runApp(FoxMusic(
    musicData: musicData,
    downloadData: downloadData,
    accountData: accountData,
    connection: connection,
  ));
}

class FoxMusic extends StatefulWidget {
  final MusicData musicData;
  final MusicDownloadData downloadData;
  final AccountData accountData;
  final ConnectionsCheck connection;

  FoxMusic(
      {this.downloadData,
      this.musicData,
      this.accountData,
      this.connection});

  @override
  FoxMusicState createState() => FoxMusicState();
}

class FoxMusicState extends State<FoxMusic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ConnectionsCheck connection = ConnectionsCheck.instance;

  void asyncInit() async {
    await connection.initialise();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentAppVersion;

    if (connection.isOnline) {
      currentAppVersion = await Api.appVersionGet();
      if (currentAppVersion != null)  SharedPrefs.saveLastVersion(currentAppVersion);
    } else {
      currentAppVersion = await  SharedPrefs.getLastVersion();
    }
    if (currentAppVersion != null &&
        packageInfo.version != currentAppVersion['version']) {
      await pickDialog(context, 'New version available',
          currentAppVersion['update_details'], currentAppVersion['url']);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Image.asset('assets/images/audio-cover.png');

    return CupertinoApp(
      key: _scaffoldKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
          primaryColor: Color.fromRGBO(193, 39, 45, 1),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: HexColor('#222222')),
      home: MainPage(
        musicData: widget.musicData,
        downloadData: widget.downloadData,
        accountData: widget.accountData,
        connection: connection,
      ),
    );
  }
}
