import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_clock/engine/alarm_engine.dart';
import 'package:alarm_clock/models/alarm.dart';
import 'package:alarm_clock/models/holiday_cache.dart';

void main() {
  final weekdayAlarm = Alarm(
    name: 'Work',
    time: '07:30',
    rule: AlarmRule.weekday,
    soundType: SoundType.builtin,
    soundPath: 'test.mp3',
  );

  final cache = HolidayCache(
    year: 2026,
    holidays: ['2026-05-01'],
    makeupDays: ['2026-05-03'],
  );

  group('AlarmEngine', () {
    test('weekday alarm fires on Monday', () {
      final monday = DateTime(2026, 4, 27);
      expect(AlarmEngine.shouldFire(weekdayAlarm, monday, cache), true);
    });

    test('weekday alarm does NOT fire on Saturday', () {
      final saturday = DateTime(2026, 4, 25);
      expect(AlarmEngine.shouldFire(weekdayAlarm, saturday, cache), false);
    });

    test('weekday alarm does NOT fire on holiday (May 1st)', () {
      final holidayFriday = DateTime(2026, 5, 1);
      expect(AlarmEngine.shouldFire(weekdayAlarm, holidayFriday, cache), false);
    });

    test('weekday alarm fires on makeup workday (May 3rd, Sunday)', () {
      final makeupSunday = DateTime(2026, 5, 3);
      expect(AlarmEngine.shouldFire(weekdayAlarm, makeupSunday, cache), true);
    });

    test('daily alarm fires on holiday', () {
      final dailyAlarm = weekdayAlarm.copyWith(rule: AlarmRule.daily);
      final holiday = DateTime(2026, 5, 1);
      expect(AlarmEngine.shouldFire(dailyAlarm, holiday, cache), false);
    });

    test('daily alarm fires on normal day', () {
      final dailyAlarm = weekdayAlarm.copyWith(rule: AlarmRule.daily);
      final normal = DateTime(2026, 4, 28);
      expect(AlarmEngine.shouldFire(dailyAlarm, normal, cache), true);
    });

    test('custom days alarm (Mon/Wed/Fri)', () {
      final customAlarm = weekdayAlarm.copyWith(
        rule: AlarmRule.custom,
        customDays: [1, 3, 5],
      );
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 27), null), true);
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 28), null), false);
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 29), null), true);
    });

    test('null holidayCache falls through to base rule', () {
      final friday = DateTime(2026, 5, 1);
      expect(AlarmEngine.shouldFire(weekdayAlarm, friday, null), true);
    });
  });
}
