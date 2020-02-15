import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/functions/format/fromatSongName.dart';

saveSong(Song song, BuildContext context, bytes) async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filename = await formatFileName(song);
    if (File('$dir/songs/$filename').existsSync()) {
      infoDialog(context, 'Error',
          'Song with name: \n${song.toString()} aredy exist!');
      return false;
    }
    File file = new File('$dir/songs/$filename');
    await file.writeAsBytes(bytes);
    return true;
  } catch (e) {
    print(e);
  }
  return false;
}
