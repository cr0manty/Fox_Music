import 'dart:convert';

Song songFromJson(String str) {
  final data = json.decode(str);
  return Song.fromJson(data);
}

String songToJson(Song data) {
  final str = data.toJson();
  return json.encode(str);
}

class Song {
  String name;
  String artist;
  String download;
  String path;
  int duration;
  int song_id;

  Song(
      {this.song_id,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.path});

  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      name: json['name'],
      artist: json['artist'],
      duration: json['duration'],
      download: json['download'],
      song_id: json['song_id'],
      path: json['path']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'artist': artist,
        'duration': duration,
        'download': download,
        'song_id': song_id,
        'path': path != null ? path : "",
      };
}
