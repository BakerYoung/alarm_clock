import '../models/alarm.dart';
import '../models/holiday_cache.dart';

class AlarmEngine {
  /// Returns true if the alarm should fire on [date].
  /// Decision: makeupDay > holiday > baseRule
  static bool shouldFire(Alarm alarm, DateTime date, HolidayCache? holidayCache) {
    final weekday = date.weekday; // 1=Mon ... 7=Sun
    final dateStr = _formatDate(date);

    // Level 2 override: today is a makeup workday → fire
    if (holidayCache != null && holidayCache.makeupDays.contains(dateStr)) {
      return true;
    }

    // Level 2 override: today is a holiday → don't fire
    if (holidayCache != null && holidayCache.holidays.contains(dateStr)) {
      return false;
    }

    // Level 1: base rule matching
    return _matchesRule(alarm, weekday);
  }

  static bool _matchesRule(Alarm alarm, int weekday) {
    switch (alarm.rule) {
      case AlarmRule.once:
        return false;
      case AlarmRule.daily:
        return true;
      case AlarmRule.weekday:
        return weekday >= 1 && weekday <= 5;
      case AlarmRule.custom:
        final customDay = weekday == 7 ? 0 : weekday;
        return alarm.customDays.contains(customDay);
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
