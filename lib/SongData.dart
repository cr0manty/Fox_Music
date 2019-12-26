class Song {
  String name;
  String artist;
  String duration;
  String download;
  int songId;
  DateTime postedAt;

  Song(
      {this.songId,
      this.artist,
      this.name,
      this.duration,
      this.download,
      this.postedAt});
}
