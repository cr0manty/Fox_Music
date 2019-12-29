import 'package:vk_parse/functions/formatTime.dart';

class Song {
  String name;
  String artist;
  String duration;
  String download;
  int songId;
  DateTime postedAt;

  Song({this.songId,
    this.artist,
    this.name,
    this.duration,
    this.download,
    this.postedAt});

  Song.fromJson(Map<String, dynamic> jsonData)
      : name = jsonData['name'],
        artist = jsonData['artist'],
        duration = formatTime(jsonData['duration']),
        songId = jsonData['song_id'],
        postedAt = DateTime.parse(jsonData['posted_at']),
        download = jsonData['download'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'artist': artist,
        'duration': duration,
        'download': download,
        'songId': songId,
        'postedAt': postedAt,
      };
}
