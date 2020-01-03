import 'package:audioplayers/audioplayers.dart';

playSong(String url) async {
  AudioPlayer audioPlayer = AudioPlayer();
  int result = await audioPlayer.play(url);
  if (result == 1) {
    return true;
  }
}
