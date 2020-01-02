import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/User.dart';

saveCurrentLogin(Map responseJson) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  var user;
  if ((responseJson != null && !responseJson.isEmpty)) {
    user = User.fromJson(responseJson).username;
  } else {
    user = "";
  }
  var token = (responseJson != null && !responseJson.isEmpty)
      ? User.fromJson(responseJson).token
      : "";

  await preferences.setString(
      'LastUser', (user != null && user.length > 0) ? user : "");
  await preferences.setString(
      'LastToken', (token != null && token.length > 0) ? token : "");
}
