import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/get/getToken.dart';

requestMusicListGet(BuildContext context) async {
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
      infoDialog(context, "Unable to get Music List", "Something went wrong.");
      return null;
    }
  } catch (e) {
    print(e);
    infoDialog(context, "Unable to get Music List", "Something went wrong.");
    return null;
  }
}

requestMusicListPost(BuildContext context) async {
  try {
    final token = await getToken();
    final response = await http
        .post(SONG_LIST_URL, headers: formatToken(token))
        .timeout(Duration(minutes: 2));

    if (response.statusCode == 201) {
      var songsData = (json.decode(response.body) as Map) as Map<String, dynamic>;
      songsData.remove('songs');
      return songsData != null ? songsData : {'added': 0, 'updated': 0};
    } else {
      infoDialog(context, "Something went wrong", "Unable to get Music List.");
      return null;
    }
  } on TimeoutException catch (_) {
    infoDialog(context, "Unable to get Music List",
        "Server Error. Try to turn on VPN or use proxy.");
    return null;
  } catch (e) {
    print(e);
    infoDialog(context, "Something went wrong", "Unable to get Music List.");
    return null;
  }
}
