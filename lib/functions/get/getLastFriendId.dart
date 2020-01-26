import 'package:shared_preferences/shared_preferences.dart';

getLastFriendId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  int friendId = await preferences.getInt("LastFriendId");
  return friendId;
}
