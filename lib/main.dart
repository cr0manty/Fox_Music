import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox_music/provider/shared_prefs.dart';
import 'package:fox_music/provider/check_connection.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/provider/account_data.dart';

import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/main_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConnectionsCheck.instance.initialise();

  if (SharedPrefs.getInstance() == null) {
    await SharedPrefs.init();
  }

  MusicData musicData = MusicData();
  await AccountData.instance.init();
  MusicDownloadData downloadData = MusicDownloadData();

  await musicData.init();
  await downloadData.init(musicData, ConnectionsCheck.instance.isOnline);

  runApp(FoxMusic(
    musicData: musicData,
    downloadData: downloadData,
  ));
}

class FoxMusic extends StatefulWidget {
  final MusicData musicData;
  final MusicDownloadData downloadData;

  FoxMusic(
      {this.downloadData,
      this.musicData});

  @override
  FoxMusicState createState() => FoxMusicState();
}

class FoxMusicState extends State<FoxMusic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
          scaffoldBackgroundColor: HexColor.background()),
      home: MainPage(
        musicData: widget.musicData,
        downloadData: widget.downloadData
      ),
    );
  }
}
