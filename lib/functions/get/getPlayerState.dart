import 'package:shared_preferences/shared_preferences.dart';

getPlayerState() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  bool repeat = await preferences.getBool("RepeatState");
  return repeat ?? false;
}
