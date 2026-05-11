class HolidayCache {
  final int year;
  final List<String> holidays; // ["2026-01-01", "2026-05-01", ...]
  final List<String> makeupDays; // ["2026-05-03", ...]
  final DateTime updatedAt;

  const HolidayCache({
    required this.year,
    required this.holidays,
    required this.makeupDays,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'holidays': holidays.join(','),
      'makeupDays': makeupDays.join(','),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HolidayCache.fromMap(Map<String, dynamic> map) {
    final holidaysStr = map['holidays'] as String? ?? '';
    final makeupStr = map['makeupDays'] as String? ?? '';
    return HolidayCache(
      year: map['year'] as int,
      holidays: holidaysStr.isEmpty ? [] : holidaysStr.split(','),
      makeupDays: makeupStr.isEmpty ? [] : makeupStr.split(','),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
