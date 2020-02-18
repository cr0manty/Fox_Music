import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

musicListGet() async {
  try {
    final token = await getToken();
    final response = await http.get(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      var songsData =
          (json.decode(response.body) as Map)['result'] as List<dynamic>;

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
  return [];
}

musicListPost() async {
  try {
    final token = await getToken();
    final response =
        await http.post(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 201) {
      var songsData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;
      return songsData ?? {'added': 0, 'updated': 0};
    }
  } catch (e) {
    print(e);
  }
  return [];
}

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
  return songList;
}

hideMusic(int id) async {
  try {
    String token = await getToken();
    final response =
        await http.post(SONG_DELETE_URL + '$id', headers: formatToken(token));
    return response.statusCode == 201;
  } catch (e) {
    print(e);
  }
  return false;
}

addMusic(int id) async {
  try {
    String token = await getToken();
    final response =
        await http.post(SONG_ADD_URL + '$id', headers: formatToken(token));
    return response.statusCode == 201;
  } catch (e) {
    print(e);
  }
  return false;
}
