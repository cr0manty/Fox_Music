import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

saveCurrentLogin(Map responseJson) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  var user;
  if ((responseJson != null && !responseJson.isEmpty)) {
      var token = (responseJson != null && !responseJson.isEmpty) ? User.fromJson(responseJson).token : "";

    user = User.fromJson(responseJson).username;
  } else {
    user = "";
  }
  var token = (responseJson != null && !responseJson.isEmpty) ? User.fromJson(responseJson).token : "";
  var userId = (responseJson != null && !responseJson.isEmpty) ? User.fromJson(responseJson).userId : 0;

  await preferences.setString('LastUser', (user != null && user.length > 0) ? user : "");
  await preferences.setString('LastToken', (token != null && token.length > 0) ? token : "");
  await preferences.setInt('LastUserId', (userId != null && userId > 0) ? userId : 0);

}