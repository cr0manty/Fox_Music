import 'package:shared_preferences/shared_preferences.dart';

logout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString('LastUser', "");
  await preferences.setString('LastToken', "");
  await preferences.setInt('LastUserId', 0);

}