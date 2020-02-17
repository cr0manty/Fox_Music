import 'package:vk_parse/models/PlaylistCheckbox.dart';
import 'package:vk_parse/utils/Database.dart';

setPlaylistSong(List<PlaylistCheckbox> list) async {
  await Future.wait(list.map((checkList) async {
    if (checkList.checked)
      await checkList.playlist.addSong(checkList.songId);
    else
      await checkList.playlist.deleteSong(checkList.songId);
    await DBProvider.db.updatePlaylist(checkList.playlist);
  }));
}
