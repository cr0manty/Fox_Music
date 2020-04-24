import 'package:shared_preferences/shared_preferences.dart';

getLastVersion() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String version = await preferences.getString("Version");
  String details = await preferences.getString("Details");
  String url = await preferences.getString("SiteUrl");

  return {
    'version': version ?? '',
    'update_details': details ?? '',
    'url': url ?? ''
  };
}
