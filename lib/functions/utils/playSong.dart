import 'package:audioplayers/audioplayers.dart';

playSong(String url) async {
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'usingThisIdForPlayer');
  audioPlayer.stop();
  int result = await audioPlayer.play(url);
  if (result == 1) {
    return true;
  }
  return false;
}
