import 'package:shared_preferences/shared_preferences.dart';

logout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString('CurrentUser', "");
  await preferences.setString('CurrentToken', "");
  await preferences.setString('LastRoute', "");
}
