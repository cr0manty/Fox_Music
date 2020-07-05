import 'package:fox_music/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPrefs {
  static const _lastTab = 'LastTab';
  static const _currentUser = 'CurrentUser';
  static const _currentToken = 'CurrentToken';
  static const _repeatState = 'RepeatState';
  static const _version = 'Version';
  static const _details = 'Details';
  static const _volume = 'Volume';

  static SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences getInstance() {
    return _prefs;
  }

  static void saveLastTab(int tabIndex) {
    _prefs.setInt(_lastTab, tabIndex);
  }

  static void logout() {
    _prefs.setString(_currentUser, "");
    _prefs.setString(_currentToken, "");
  }

  static void savePlayerState(bool repeat) async {
    _prefs.setBool(_repeatState, repeat);
  }

  static void saveToken(String token) {
    _prefs.setString(
        _currentToken, (token != null && token.length > 0) ? token : "");
  }

  static void saveUser(User user) {
    _prefs.setString(_currentUser, userToJson(user));
  }

  static void saveLastVersion(Map version) {
    if (version != null) {
      _prefs.setString(_version, version['version']);
      _prefs.setString(_details, version['update_details']);
    }
  }

  static Map getLastVersion() {
    String version = _prefs.getString(_version);
    String details = _prefs.getString(_details);

    return version != null || details != null
        ? {
            'version': version ?? '',
            'update_details': details ?? '',
          }
        : null;
  }

  static Map getPlayerState() {
    bool repeat = _prefs.getBool(_repeatState);
    double volume = _prefs.getDouble(_volume);
    return {'repeat': repeat ?? false, 'volume': volume == null ? 1.0 : volume};
  }

  static String getToken() {
    return _prefs.getString(_currentToken);
  }

  static User getUser() {
    String jsonUser = _prefs.getString(_currentUser);
    User user = userFromJson(jsonUser);
    return user;
  }

  static int getLastTab() {
    return _prefs.getInt(_lastTab) ?? 0;
  }
}
