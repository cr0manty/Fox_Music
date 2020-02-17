import 'package:vk_parse/models/Playlist.dart';
import 'package:vk_parse/utils/Database.dart';

setPlaylistSong(List<Playlist> list, int songId) async {
  await Future.wait(list.map((playlist) async {
    if (playlist.notInList(songId))
      await playlist.addSong(songId);
    else
      await playlist.deleteSong(songId);
    await DBProvider.db.updatePlaylist(playlist);
  }));
}
