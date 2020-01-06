import 'package:shared_preferences/shared_preferences.dart';

saveLogout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt('CurrentUserId', -1);
  await preferences.setString('CurrentToken', "");
}