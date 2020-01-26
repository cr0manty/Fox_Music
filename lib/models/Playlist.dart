import 'package:vk_parse/models/Song.dart';

Playlist fromFile(String filePath) {
  Playlist playlist;
  return playlist;
}

class Playlist {
  String id;
  List<Song> songList;
  String image;
  String title;

  Playlist({this.id, this.title, this.songList, this.image});
}
