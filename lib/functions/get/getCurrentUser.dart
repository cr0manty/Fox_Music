import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/User.dart';

getCurrentUser() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  User user = userFromJson(await preferences.getString("CurrentUser"));
  return user;
}
