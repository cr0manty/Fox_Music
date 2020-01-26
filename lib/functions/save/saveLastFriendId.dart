import 'package:shared_preferences/shared_preferences.dart';

saveLastFriendId(int friendId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt('LastFriendId', friendId);
}
