import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/database.dart';

setPlaylistSong(List<PlaylistCheckbox> list, int songId) async {
  await Future.wait(list.map((playlistChecked) async {
    if (playlistChecked.checked)
      await playlistChecked.playlist.addSong(songId);
    else
      await playlistChecked.playlist.deleteSong(songId);
    await DBProvider.db.updatePlaylist(playlistChecked.playlist);
  }));
}
