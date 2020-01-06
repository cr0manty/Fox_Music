import 'package:shared_preferences/shared_preferences.dart';

getUserId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  int userId = await preferences.getInt("CurrentUserId");
  return userId;
}
