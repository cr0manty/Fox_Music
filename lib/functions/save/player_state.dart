import 'package:shared_preferences/shared_preferences.dart';

savePlayerState(bool repeat, bool mix) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setBool('RepeatState', repeat);
  await preferences.setBool('MixState', mix);
}
