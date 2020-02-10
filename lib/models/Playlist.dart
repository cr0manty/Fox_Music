import 'dart:convert';

Playlist playlistFromJson(String str) {
  if (str != null) {
    final data = json.decode(str);
    return Playlist.fromJson(data);
  }
}

String playlistToJson(Playlist data) {
  final str = data.toJson();
  return json.encode(str);
}

class Playlist {
  int id;
  String title;
  String image;
  String songList;

  Playlist({this.id, this.image, this.title, this.songList}) {
    songList ??= '';
  }

  factory Playlist.fromJson(Map<String, dynamic> json) => new Playlist(
      title: json['title'],
      id: json['id'],
      image: json['image'],
      songList: json['songList']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'songList': songList,
      };

  List<String> _splitSongList() {
    return songList.split(',');
  }

  getImage() {
    return base64.decode(image);
  }

  bool inList(int id) {
    List<String> data = _splitSongList();
    return data.indexOf(id.toString()) != -1;
  }

  notInList(int id) {
    return !inList(id);
  }

  addSong(int id) {
    if (notInList(id)) {
      songList += '$id,';
    }
  }

  deleteSong(int id) {
    if (inList(id)) {
      _splitSongList().forEach((data) {
        if (data != id.toString()) {
          songList += data;
        }
      });
    }
  }
}
