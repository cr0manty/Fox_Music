import 'package:flutter/cupertino.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/utils/help_tools.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:package_info/package_info.dart';
import 'package:fox_music/instances/api.dart';
import 'check_connection.dart';

class Utils {
  Utils._internal();

  bool _versionChecked = false;
  bool keyboardActive = false;
  bool playerUsing = false;

  static final Utils _instance = Utils._internal();

  static Utils get instance => _instance;

  void cache() async {
    precacheImage(AssetImage('assets/images/audio-cover.png'),
        KeyHolder().key.currentContext);
  }

  void init() async {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardActive = visible;
      },
    );
  }

  void checkVersion(BuildContext context) async {
    if (!_versionChecked) {
      _versionChecked = true;
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
        HelpTools.pickDialog(context, 'New version available',
            currentAppVersion['update_details'], currentAppVersion['url']);
      }
    }
  }
}
