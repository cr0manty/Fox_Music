import 'package:shared_preferences/shared_preferences.dart';

savePlayerState(bool repeat) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setBool('RepeatState', repeat);
}
