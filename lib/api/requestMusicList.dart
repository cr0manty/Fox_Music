import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

requestMusicListGet() async {
  try {
    final token = await getToken();
    final response = await http.get(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      var songsData =
          (json.decode(response.body) as Map)['songs'] as List<dynamic>;

      var songList = List<Song>();
      songsData.forEach((dynamic value) async {
        var song = new Song.fromJson(value);
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
      var songsData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;
      songsData.remove('songs');
      return songsData ?? {'added': 0, 'updated': 0};
    }
  } catch (e) {
    print(e);
  }
}
