String formatDuration(int time) {
  Duration duration = Duration(seconds: time.round());
  return [duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}

String timeFormat(double value) {
  Duration time = Duration(seconds: value.round());
  return [time.inMinutes, time.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}

int durToInt(Duration time) {
  if (time != null) return time.inSeconds;
  return 0;
}
