import 'package:timezone/timezone.dart' as tz;

const cairoTimeZoneName = 'Africa/Cairo';

tz.Location get _cairoLocation => tz.getLocation(cairoTimeZoneName);

DateTime nowInCairo() => tz.TZDateTime.now(_cairoLocation);

DateTime cairoDateTimeFromUtc(DateTime value) =>
    tz.TZDateTime.from(value.toUtc(), _cairoLocation);

DateTime cairoTodayMidnight() {
  final now = nowInCairo();
  return tz.TZDateTime(_cairoLocation, now.year, now.month, now.day);
}

DateTime cairoMaxBookableDate() =>
    cairoTodayMidnight().add(const Duration(days: 90));
