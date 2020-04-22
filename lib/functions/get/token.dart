import 'package:shared_preferences/shared_preferences.dart';

getToken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String token = await preferences.getString("CurrentToken");
  return token ?? '';
}
