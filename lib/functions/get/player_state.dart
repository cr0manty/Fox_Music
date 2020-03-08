import 'package:shared_preferences/shared_preferences.dart';

getPlayerState() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  bool repeat = await preferences.getBool("RepeatState");
  double volume = await preferences.getDouble("Volume");
  return {'repeat': repeat ?? false, 'volume': volume == null ? 1.0 : volume};
}
