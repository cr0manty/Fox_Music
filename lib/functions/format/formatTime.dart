String formatTime(int time) {
  Duration duration = Duration(seconds: time.round());
  return [duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}
