import 'dart:io';
import 'package:path_provider/path_provider.dart';

getLocalSongs() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return Directory("$dir/songs/").listSync();
}
