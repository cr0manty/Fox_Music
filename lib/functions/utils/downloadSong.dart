import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/formatFileName.dart';

downloadSong(BuildContext context, Song song) async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    final Directory _appDocDirFolder = Directory('$dir/songs/');
    if (!await _appDocDirFolder.exists()) {
      await _appDocDirFolder.create(recursive: true);
    }

    String filename = formatFileName(song);
    if (File('$dir/songs/$filename').existsSync()) {
      infoDialog(context, 'Error', 'Song with name: \n$filename aredy downloaded!');
      return null;
    }

    File file = new File('$dir/songs/$filename');
    var request = await http.get(
      song.download,
    );
    var bytes = await request.bodyBytes;
    await file.writeAsBytes(bytes);
    print(file.path);
    infoDialog(context, 'Success', 'Song $filename successfully downloaded!');
  } catch (e) {
    infoDialog(context, 'Error',
        'Something went wrong while downloading. Try to refresh song list');
    print(e);
  }
}
