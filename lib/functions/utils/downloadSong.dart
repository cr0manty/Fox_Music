import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/Song.dart';

downloadSong(BuildContext context, Song song) async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filename =
        '${song.artist.split(' ').join('_')}-${song.name.split(' ').join('_')}';
    File file = new File('$dir/${filename}.mp3');
    var request = await http.get(
      song.download,
    );
    var bytes = await request.bodyBytes;
    await file.writeAsBytes(bytes);
    print(file.path);
    infoDialog(context, 'Success', 'Song $filename successfully downloaded!');
  } catch (e) {
    infoDialog(context, 'Error', 'Something went wrong while downloading. Try to refresh song list');
    print(e);
  }
}
