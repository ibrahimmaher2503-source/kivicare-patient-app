// UTC+02 — Africa/Cairo wall-clock. DST: Egypt suspended DST in 2011; if Egypt
// reintroduces DST this helper must be updated to reflect the new offset.
DateTime nowInCairo() => DateTime.now().toUtc().add(const Duration(hours: 2));

DateTime cairoTodayMidnight() {
  final now = nowInCairo();
  return DateTime(now.year, now.month, now.day);
}

DateTime cairoMaxBookableDate() => cairoTodayMidnight().add(const Duration(days: 90));
