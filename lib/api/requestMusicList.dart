import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';
import 'package:vk_parse/models/Database.dart';

requestMusicListGet() async {
  try {
    final token = await getToken();
    final response = await http.get(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      int userId = (json.decode(response.body) as Map)['user'] as int;
      var songsData =
          (json.decode(response.body) as Map)['songs'] as List<dynamic>;

      var songList = List<Song>();
      songsData.forEach((dynamic value) async {
        var song = Song(
            name: value['name'],
            artist: value['artist'],
            duration: value['duration'],
            songId: value['song_id'],
            postedAt: value['posted_at'],
            download: value['download'],
            userId: userId);
        songList.add(song);
      });
      return songList.reversed.toList();
    }
  } catch (e) {
    print(e);
  }
}

requestMusicListPost() async {
  try {
    final token = await getToken();
    final response =
        await http.post(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 201) {
      int userId = (json.decode(response.body) as Map)['user'] as int;

      var songsData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;
      (songsData['songs'] as List<dynamic>).forEach((dynamic value) async {
        var song = Song(
            name: value['name'],
            artist: value['artist'],
            duration: value['duration'],
            songId: value['song_id'],
            postedAt: value['posted_at'],
            download: value['download'],
            userId: userId);
        await DBProvider.db.newSong(song);
      });
      songsData.remove('songs');
      return songsData != null ? songsData : {'added': 0, 'updated': 0};
    }
  } catch (e) {
    print(e);
  }
}
