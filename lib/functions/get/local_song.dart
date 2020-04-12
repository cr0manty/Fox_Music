import 'dart:io';
import 'package:path_provider/path_provider.dart';

saveLocalSongs() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return Directory("$dir/songs/").listSync();
}
