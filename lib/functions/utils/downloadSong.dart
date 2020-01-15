import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';

downloadSong(Song song, {BuildContext context}) async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    final Directory _appDocDirFolder = Directory('$dir/songs/');
    if (!await _appDocDirFolder.exists()) {
      await _appDocDirFolder.create(recursive: true);
    }
    String filename = formatFileName(song);
    if (context != null && File('$dir/songs/$filename').existsSync()) {
      infoDialog(
          context, 'Error', 'Song with name: \n$filename aredy downloaded!');
      return null;
    }

    var request = await http
        .get(
          song.download,
        )
        .timeout(Duration(minutes: 2));
    if (request.statusCode == 200) {
      File file = new File('$dir/songs/$filename');
      var bytes = await request.bodyBytes;
      await file.writeAsBytes(bytes);

      if (context != null) {
        infoDialog(
            context, 'Success', 'Song $filename successfully downloaded!');
      }
    } else {
      throw "Connection erroe";
    }
  } on TimeoutException catch (e) {
    if (context != null) {
      infoDialog(context, 'Error',
          'Something went wrong while downloading. Try to refresh song list');
    }
    print(e);
  } catch (e) {
    if (context != null) {
      infoDialog(context, 'Error',
          'Something went wrong while downloading. Try to refresh song list');
    }
    print(e);
  }
}
