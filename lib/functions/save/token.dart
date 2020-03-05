import 'package:shared_preferences/shared_preferences.dart';

saveToken(String token) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString(
      'CurrentToken', (token != null && token.length > 0) ? token : "");
}
