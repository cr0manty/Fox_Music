class Song {
  String name;
  String artist;
  String duration;
  String download;
  int song_id;
  DateTime posted_at;

  Song(
      {this.song_id,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.posted_at});
}
