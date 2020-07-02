import 'package:fox_music/models/song.dart';
import 'package:fox_music/provider/api.dart';

downloadAll() async { // TODO
  try {
    List<Song> songList = await Api.musicListGet();
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
