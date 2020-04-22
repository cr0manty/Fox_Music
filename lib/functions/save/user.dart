import 'package:fox_music/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveUser(User user) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString('CurrentUser', userToJson(user));
}
