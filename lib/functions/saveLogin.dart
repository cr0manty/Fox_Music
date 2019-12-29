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
  var userId = (responseJson != null && !responseJson.isEmpty)
      ? User.fromJson(responseJson).userId
      : 0;
  var password = (responseJson != null && !responseJson.isEmpty)
      ? User.fromJson(responseJson).password
      : "";

  await preferences.setString(
      'LastUser', (user != null && user.length > 0) ? user : "");
  await preferences.setString(
      'LastToken', (token != null && token.length > 0) ? token : "");
  await preferences.setInt(
      'LastUserId', (userId != null && userId > 0) ? userId : 0);
  await preferences.setString('LastPassword',
      (password != null && password.length > 0) ? password : "");
}
