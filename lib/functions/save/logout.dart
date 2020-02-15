import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

logout() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString('CurrentUser', "");
  await preferences.setString('CurrentToken', "");
}
