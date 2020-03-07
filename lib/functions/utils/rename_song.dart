import 'dart:io';

import 'package:fox_music/functions/format/song_name.dart';
import 'package:fox_music/models/song.dart';
import 'package:path_provider/path_provider.dart';

renameSong(Song song) async {
  String newFileName = await formatFileName(song);
  String dir = (await getApplicationDocumentsDirectory()).path;

  File oldSong = File(song.path);
  File newSong = new File('$dir/songs/$newFileName');

  var bytes = await oldSong.readAsBytes();
  await newSong.writeAsBytes(bytes);
  await oldSong.delete();
}
