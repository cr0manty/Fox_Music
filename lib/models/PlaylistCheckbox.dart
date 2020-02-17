import 'package:vk_parse/models/Playlist.dart';

class PlaylistCheckbox {
  int songId;
  Playlist playlist;
  bool checked;

  PlaylistCheckbox(this.playlist, {this.checked, this.songId}) {
    checked ??= false;
  }
}