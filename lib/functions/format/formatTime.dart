String formatDuration(int time) {
  Duration duration = Duration(seconds: time.round());
  return [duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}

String timeFormat(Duration time) {
  return [time.inMinutes, time.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}


int durToInt(Duration time) {
  if (time != null)
    return time.inSeconds + time.inMinutes;
  return 0;
}