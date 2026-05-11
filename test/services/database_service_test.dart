import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:alarm_clock/models/alarm.dart';
import 'package:alarm_clock/models/holiday_cache.dart';
import 'package:alarm_clock/services/database_service.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    db = DatabaseService();
  });

  tearDown(() async {
    final d = await db.database;
    await d.close();
    DatabaseService._db = null;
  });

  test('insert and retrieve alarm', () async {
    final alarm = Alarm(
      name: 'Work',
      time: '07:30',
      rule: AlarmRule.weekday,
      soundType: SoundType.builtin,
      soundPath: 'assets/ringtones/default.mp3',
    );
    await db.insertAlarm(alarm);
    final alarms = await db.getAlarms();
    expect(alarms.length, 1);
    expect(alarms.first.name, 'Work');
    expect(alarms.first.time, '07:30');
  });

  test('update alarm', () async {
    final alarm = Alarm(
      name: 'Work',
      time: '07:30',
      rule: AlarmRule.weekday,
      soundType: SoundType.builtin,
      soundPath: 'assets/ringtones/default.mp3',
    );
    final id = await db.insertAlarm(alarm);
    final updated = alarm.copyWith(id: id, name: 'Early Work', enabled: false);
    await db.updateAlarm(updated);
    final alarms = await db.getAlarms();
    expect(alarms.first.name, 'Early Work');
    expect(alarms.first.enabled, false);
  });

  test('delete alarm', () async {
    final alarm = Alarm(
      name: 'Work',
      time: '07:30',
      rule: AlarmRule.weekday,
      soundType: SoundType.builtin,
      soundPath: 'assets/ringtones/default.mp3',
    );
    final id = await db.insertAlarm(alarm);
    await db.deleteAlarm(id);
    final alarms = await db.getAlarms();
    expect(alarms.length, 0);
  });

  test('upsert and retrieve holiday cache', () async {
    final cache = HolidayCache(
      year: 2026,
      holidays: ['2026-01-01', '2026-05-01'],
      makeupDays: ['2026-05-03'],
    );
    await db.upsertHolidayCache(cache);
    final retrieved = await db.getHolidayCache(2026);
    expect(retrieved, isNotNull);
    expect(retrieved!.holidays, contains('2026-01-01'));
    expect(retrieved.makeupDays, contains('2026-05-03'));
  });
}
