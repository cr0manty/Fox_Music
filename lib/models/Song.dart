import 'package:vk_parse/functions/format/formatTime.dart';
import 'dart:convert';

Song clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Song.fromJson(jsonData);
}

String clientToJson(Song data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Song {
  String name;
  String artist;
  String duration;
  String download;
  String localUrl;
  int songId;
  DateTime postedAt;

  Song(
      {this.songId,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.postedAt,
      this.localUrl});

  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      name: json['name'],
      artist: json['artist'],
      duration: formatTime(json['duration']),
      songId: json['song_id'],
      localUrl: json['localUrl'],
      postedAt: DateTime.parse(json['posted_at']),
      download: json['download']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'artist': artist,
        'duration': duration,
        'download': download,
        'songId': songId,
        'postedAt': postedAt,
        'localUrl': localUrl,
      };
}
