import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/User.dart';

saveCurrentUser(int userId, String token) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt(
      'LastUserId', (userId != null && userId > 0) ? userId : "");
  await preferences.setString(
      'LastToken', (token != null && token.length > 0) ? token : "");
}
