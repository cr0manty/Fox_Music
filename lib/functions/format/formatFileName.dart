import 'package:vk_parse/models/Song.dart';

splitString(String str) {
  return str.split('/').join(' ').split(' ').join('_');
}

formatFileName(Song song) {
  return '${splitString(song.artist)}-${splitString(song.name)}.mp3';
}