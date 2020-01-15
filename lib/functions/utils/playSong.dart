import 'package:audioplayers/audioplayers.dart';

playSong(String url) async {
  AudioPlayer audioPlayer = AudioPlayer();
  int result = await audioPlayer.play(url).timeout(Duration(seconds: 10));
  if (result == 1) {
    return true;
  }
  return false;
}
