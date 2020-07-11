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
  int songId;
  int inMyList;
  bool downloaded;
  bool inPlaylist;

  Song(
      {this.songId,
      this.artist,
      this.title,
      this.duration,
      this.download,
      this.path,
      this.inMyList})
      : downloaded = false,
        inPlaylist = false;

  @override
  int get hashCode => songId.hashCode;

  bool operator ==(o) => title == o.title && artist == o.artist;

  @override
  toString() {
    return '$artist - $title';
  }

  static String splitStringToFile(String str) {
    return str.replaceAll('/', ' ').replaceAll(' ', '_');
  }

  static String splitStringFromFile(String str) {
    return str.replaceAll('_', ' ');
  }

  static Song formatSong(String path) {
    try {
      String songData = path.substring(path.lastIndexOf('/') + 1);
      final data = songData.split('-');
      return Song(
          artist: splitStringFromFile(data[0]),
          title: splitStringFromFile(data[1]),
          duration: int.parse(data[2]),
          songId: int.parse(data[3].split('.')[0]),
          path: path);
    } catch (e) {
      return null;
    }
  }

  String formatDuration() {
    Duration time = Duration(seconds: duration.round());
    return [time.inMinutes, time.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String formatFileName(int id) {
    return '${splitStringToFile(artist)}-${splitStringToFile(title)}-$duration-$id.mp3';
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
      songId: json['song_id'],
      path: json['path'],
      inMyList: json['in_my_list']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'duration': duration,
        'download': download,
        'song_id': songId,
        'path': path ?? "",
        'in_my_list': inMyList == null ? 0 : inMyList
      };
}
