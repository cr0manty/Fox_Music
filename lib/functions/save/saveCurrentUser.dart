import 'package:shared_preferences/shared_preferences.dart';

saveCurrentUser(int userId, String token) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt(
      'CurrentUserId', (userId != null && userId > 0) ? userId : -1);
  await preferences.setString(
      'CurrentToken', (token != null && token.length > 0) ? token : "");
}
