import 'package:shared_preferences/shared_preferences.dart';

logout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt('CurrentUserId', 0);
  await preferences.setString('CurrentToken', "");

}