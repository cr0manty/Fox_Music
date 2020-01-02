import 'package:shared_preferences/shared_preferences.dart';

getLastRoute() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String route = await preferences.getString("LastRoute");
  return route;
}
