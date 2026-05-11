import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holiday_cache.dart';
import 'database_service.dart';

class HolidayService {
  final DatabaseService _db;
  static const _baseUrl = 'https://timor.tech/api/holiday/year';

  HolidayService(this._db);

  Future<HolidayCache> getHolidays(int year) async {
    final cached = await _db.getHolidayCache(year);
    if (cached != null) return cached;

    return fetchAndCache(year);
  }

  Future<HolidayCache> fetchAndCache(int year) async {
    final response = await http.get(Uri.parse('$_baseUrl/$year'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch holidays: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['code'] != 0) {
      throw Exception('API error: ${data['code']}');
    }

    final holidays = <String>[];
    final makeupDays = <String>[];
    final holidayMap = data['holiday'] as Map<String, dynamic>? ?? {};

    for (final entry in holidayMap.entries) {
      final info = entry.value as Map<String, dynamic>;
      final date = '$year-${entry.key}';
      if (info['holiday'] == true) {
        holidays.add(date);
      } else if (info['holiday'] == false) {
        makeupDays.add(date);
      }
    }

    final cache = HolidayCache(
      year: year,
      holidays: holidays,
      makeupDays: makeupDays,
    );

    await _db.upsertHolidayCache(cache);
    return cache;
  }

  Future<HolidayCache> refresh(int year) async {
    return fetchAndCache(year);
  }
}
