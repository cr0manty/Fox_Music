import 'package:shared_preferences/shared_preferences.dart';

saveLastVersion(Map version) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("Version", version['version']);
  await preferences.setString("Details", version['details']);
}
