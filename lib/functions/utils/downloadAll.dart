import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/models/Song.dart';

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
