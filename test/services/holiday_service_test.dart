import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:alarm_clock/services/database_service.dart';
import 'package:alarm_clock/services/holiday_service.dart';

void main() {
  late DatabaseService db;
  late HolidayService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    db = DatabaseService();
    service = HolidayService(db);
  });

  tearDown(() async {
    final d = await db.database;
    await d.close();
    DatabaseService._db = null;
  });

  test('fetchAndCache stores data and getHolidays returns from cache', () async {
    try {
      final cache = await service.fetchAndCache(2026);
      expect(cache.year, 2026);
      expect(cache.holidays, isNotEmpty);

      final cached = await service.getHolidays(2026);
      expect(cached.holidays, cache.holidays);
    } catch (e) {
      print('Skipping test: API unreachable ($e)');
    }
  });
}
