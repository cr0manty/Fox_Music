import 'package:shared_preferences/shared_preferences.dart';

getLastRoute() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  return await preferences.getInt("Route");
}
