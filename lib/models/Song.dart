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
  String postedAt;
  int duration;
  int userId;
  int songId;

  Song(
      {this.songId,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.postedAt,
      this.localUrl,
      this.userId});

  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      name: json['name'],
      artist: json['artist'],
      duration: json['duration'],
      songId: json['song_id'],
      userId: json['user'],
      localUrl: json['localUrl'],
      postedAt: json['posted_at'],
      download: json['download']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'artist': artist,
        'duration': duration,
        'download': download,
        'songId': songId,
        'postedAt': postedAt,
        'localUrl': localUrl,
        'userId': userId,
      };
}
