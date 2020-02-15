import 'package:vk_parse/models/Song.dart';

splitStringToFile(String str) {
  return str.replaceAll('/', ' ').replaceAll(' ', '_');
}

formatFileName(Song song) {
  return '${splitStringToFile(song.artist)}-${splitStringToFile(song.title)}-${song.duration}-${song.song_id}.mp3';
}

splitStringFromFile(String str) {
  return str.replaceAll('_', ' ');
}

formatSong(String path) {
  try {
    String songData = path.substring(path.lastIndexOf('/') + 1);
    final data = songData.split('-');
    return Song(
        artist: splitStringFromFile(data[0]),
        title: splitStringFromFile(data[1]),
        duration: int.parse(data[2]),
        song_id: int.parse(data[3].split('.')[0]),
        path: path);
  } catch (e) {
    return null;
  }
}
