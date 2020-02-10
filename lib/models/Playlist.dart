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

  Playlist(
      {this.id,
      this.image,
      this.title,
      this.songList});

  factory Playlist.fromJson(Map<String, dynamic> json) => new Playlist(
      title: json['name'],
      id: json['id'],
      image: json['image'],
      songList: json['songList']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'songList': songList,
      };

  getImage() {
    return base64.decode(image);
  }
}
