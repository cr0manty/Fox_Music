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

  Playlist({this.id, this.image, this.title, this.songList}) {
    songList ??= '';
  }

  factory Playlist.fromJson(Map<String, dynamic> json) => new Playlist(
      title: json['title'],
      id: json['id'],
      image: json['image'],
      songList: json['songList']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'songList': songList,
      };

  List<String> splitSongList() {
    return songList.split(',');
  }

  bool inList(int id) {
    List<String> data = splitSongList();
    return data.indexOf(id.toString()) != -1;
  }

  notInList(int id) {
    return !inList(id);
  }

  addSong(int id) {
    if (notInList(id)) {
      songList += '$id,';
    }
  }

  deleteSong(int id) {
    String newList = '';

    if (inList(id)) {
      final list = splitSongList();
      list.forEach((data) {
        if (data != id.toString()) {
          newList += data;
        }
      });
    }
    songList = newList;
  }
}

class PlaylistCheckbox {
  int songId;
  Playlist playlist;
  bool checked;

  PlaylistCheckbox(this.playlist, {this.checked, this.songId}) {
    checked ??= false;
  }
}
