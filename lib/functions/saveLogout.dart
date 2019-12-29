import 'package:shared_preferences/shared_preferences.dart';

saveLogout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString('LastUser', "");
  await preferences.setString('LastToken', "");
  await preferences.setString('LastPassword', "");
  await preferences.setInt('LastUserId', 0);
}