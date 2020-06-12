import 'package:shared_preferences/shared_preferences.dart';

getLastVersion() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String version = await preferences.getString("Version");
  String details = await preferences.getString("Details");

  return version != null || details != null
      ? {
          'version': version ?? '',
          'update_details': details ?? '',
        }
      : null;
}
