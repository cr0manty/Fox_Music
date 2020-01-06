import 'package:flutter/material.dart';

import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/Song.dart';

downloadAll(BuildContext context) async {
  List<Song> songList = await requestMusicListGet();
  int downloadAmount = 0;
  songList.forEach((Song song) async {
    try {
      await downloadSong(song);
      downloadAmount++;
    } catch (e) {
      print(e);
    }
  });
  await infoDialog(context, "Downloader", "$downloadAmount songs downloaded");
}
