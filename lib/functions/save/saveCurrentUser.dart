import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/User.dart';

saveCurrentUser(User user) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString(
      'CurrentUser', (user != null) ? userToJson(user) : "");
  await preferences.setString(
      'CurrentToken', (user.token != null && user.token.length > 0) ? user.token : "");
}
