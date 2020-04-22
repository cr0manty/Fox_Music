import 'package:fox_music/api/music_list.dart';
import 'package:fox_music/models/song.dart';

downloadAll() async { // TODO
  try {
    List<Song> songList = await musicListGet();
    int downloadAmount = 0;
    await songList.forEach((Song song) async {
      try {
        downloadAmount++;
      } catch (e) {
        print(e);
      }
    });
    return downloadAmount;
  } catch (e) {
    print(e);
    return -1;
  }
}
