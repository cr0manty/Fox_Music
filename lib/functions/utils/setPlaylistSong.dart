import 'package:vk_parse/models/PlaylistCheckbox.dart';
import 'package:vk_parse/utils/Database.dart';

setPlaylistSong(List<PlaylistCheckbox> list, int songId) async {
  await Future.wait(list.map((playlistChecked) async {
    if (playlistChecked.checked)
      await playlistChecked.playlist.addSong(songId);
    else
      await playlistChecked.playlist.deleteSong(songId);
    await DBProvider.db.updatePlaylist(playlistChecked.playlist);
  }));
}
