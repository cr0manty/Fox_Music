import 'package:shared_preferences/shared_preferences.dart';
import 'package:vk_parse/models/Song.dart';

savePlayedSong(Song song) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setString(
      'PlayedSong', (song != null) ? songToJson(song) : null);
}
