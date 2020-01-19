import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/Song.dart';

getPlayedSong() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  Song playedSong = songFromJson(await preferences.getString("PlayedSong"));
  return playedSong;
}
