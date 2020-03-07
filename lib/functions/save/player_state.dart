import 'package:shared_preferences/shared_preferences.dart';

savePlayerState(bool repeat, double volume) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setBool('RepeatState', repeat);
  await preferences.setDouble('Volume', volume);
}
