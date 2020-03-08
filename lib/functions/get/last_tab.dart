import 'package:shared_preferences/shared_preferences.dart';

getLastTab() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  int lastTab = await preferences.getInt("LastTab");
  return lastTab ?? 0;
}
