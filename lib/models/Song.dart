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
  String localUrl;
  String posted_at;
  String updated_at;
  int duration;
  int user_id;
  int song_id;

  Song(
      {this.song_id,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.updated_at,
      this.posted_at,
      this.localUrl,
      this.user_id});

  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      name: json['name'],
      artist: json['artist'],
      duration: json['duration'],
      download: json['download'],
      song_id: json['song_id'],
      user_id: json['user'],
      localUrl: json['localUrl'],
      posted_at: json['posted_at'],
      updated_at: json['updated_at']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'artist': artist,
        'duration': duration,
        'download': download,
        'song_id': song_id,
        'posted_at': posted_at,
        'updated_at': updated_at,
        'localUrl': localUrl != null ? localUrl : "",
        'user_id': user_id != null ? user_id : -1,
      };
}
