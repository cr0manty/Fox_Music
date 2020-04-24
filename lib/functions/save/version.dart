import 'package:shared_preferences/shared_preferences.dart';

saveLastVersion(Map version) async {
  if (version != null) {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("Version", version['version']);
    await preferences.setString("Details", version['update_details']);
    await preferences.setString("SiteUrl", version['url']);
  }
}
