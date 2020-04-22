import 'package:fox_music/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

getUser() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String jsonUser = await preferences.getString("CurrentUser");
  User user = userFromJson(jsonUser);
  return user;
}
