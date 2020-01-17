import 'package:shared_preferences/shared_preferences.dart';

getLastRoute() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  int route = await preferences.getInt("Route");
  return route;
}
