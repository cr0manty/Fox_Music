import 'package:vk_parse/models/Song.dart';

splitStringToFile(String str) {
  return str.split('/').join(' ').split(' ').join('_');
}

formatFileName(Song song) {
  return '${splitStringToFile(song.artist)}-${splitStringToFile(song.name)}-${song.duration}.mp3';
}

splitStringFromFile(String str) {
  return str.split('_').join(' ');
}

formatSong(String songString, String path) {
  final data = songString.split('-');
  return Song(artist: splitStringFromFile(data[0]), name: splitStringFromFile(data[1]), duration: int.parse(data[2]),);
}