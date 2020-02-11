import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

musicSearchGet(String search) async {
  var songList = List<Song>();
  try {
    final token = await getToken();
    final searchUrl = SONG_SEARCH_URL + '?search=$search';
    final response = await http.get(searchUrl, headers: formatToken(token));

    if (response.statusCode == 200) {
      var songsData = json.decode(response.body) as List<dynamic>;

      songsData.forEach((dynamic value) async {
        var song = new Song.fromJson(value);
        songList.add(song);
      });
    }
  } catch (e) {
    print(e);
  }
  return songList.toList();
}
