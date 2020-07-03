import 'dart:convert';

Song songFromJson(String str) {
  if (str != null && str?.isNotEmpty) {
    final data = json.decode(str);
    return Song.fromJson(data);
  }
}

String songToJson(Song data) {
  final str = data.toJson();
  return json.encode(str);
}

class Song {
  String title;
  String artist;
  String download;
  String image;
  String path;
  int duration;
  int song_id;
  int in_my_list;
  bool downloaded;
  bool inPlaylist;

  Song(
      {this.song_id,
      this.artist,
      this.title,
      this.duration,
      this.download,
      this.path,
      this.in_my_list})
      : downloaded = false,
        inPlaylist = false;

  @override
  int get hashCode => song_id.hashCode;

  bool operator ==(o) => title == o.title && artist == o.artist;

  @override
  toString() {
    return '$artist - $title';
  }

  toFileName() {
    String formatArtist = artist.replaceAll(' ', '_');
    String formatTitle = title.replaceAll(' ', '_');
    return '$formatArtist-$formatTitle.mp3';
  }

  factory Song.fromJson(Map<String, dynamic> json) => Song(
      title: json['title'],
      artist: json['artist'],
      duration: json['duration'],
      download: json['download'],
      song_id: json['song_id'],
      path: json['path'],
      in_my_list: json['in_my_list']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'duration': duration,
        'download': download,
        'song_id': song_id,
        'path': path ?? "",
        'in_my_list': in_my_list == null ? 0 : in_my_list
      };
}
