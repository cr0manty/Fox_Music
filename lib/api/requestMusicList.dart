import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/functions/infoDialog.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/formatToken.dart';
import 'package:vk_parse/functions/formatTime.dart';
import 'package:vk_parse/functions/getToken.dart';

requestMusicList(BuildContext context) async {
  try {
    final token = await getToken();
    final response = await http.get(SONG_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      var songsData =
          (json.decode(response.body) as Map)['songs'] as List<dynamic>;

      var songList = List<Song>();
      songsData.forEach((dynamic value) {
        var song = Song(
            name: value['name'],
            artist: value['artist'],
            duration: formatTime(value['duration']),
            songId: value['song_id'],
            postedAt: DateTime.parse(value['posted_at']),
            download: value['download']);
        songList.add(song);
      });
      return songList.reversed.toList();
    } else {
      showTextDialog(
          context, "Unable to get Music List", "Something went wrong.", "OK");
      return null;
    }
  } catch (e) {
    print(e);
    showTextDialog(
        context, "Unable to get Music List", "Something went wrong.", "OK");
    return null;
  }
}
