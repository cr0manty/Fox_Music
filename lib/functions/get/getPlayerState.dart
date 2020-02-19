import 'package:shared_preferences/shared_preferences.dart';

getPlayerState() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  bool repeat = await preferences.getBool("RepeatState");
  bool mix = await preferences.getBool("MixState");
  return {'repeat': repeat ?? false, 'mix': mix ?? false};
}
