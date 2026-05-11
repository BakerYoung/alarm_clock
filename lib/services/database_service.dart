import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alarm.dart';
import '../models/holiday_cache.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarm_clock.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        time TEXT NOT NULL,
        rule INTEGER NOT NULL,
        customDays TEXT DEFAULT '',
        soundType INTEGER NOT NULL,
        soundPath TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        snoozeMinutes INTEGER NOT NULL DEFAULT 10,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE holiday_cache (
        year INTEGER PRIMARY KEY,
        holidays TEXT DEFAULT '',
        makeupDays TEXT DEFAULT '',
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // --- Alarm CRUD ---

  Future<int> insertAlarm(Alarm alarm) async {
    final db = await database;
    return db.insert('alarms', alarm.toMap());
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    final maps = await db.query('alarms', orderBy: 'time ASC');
    return maps.map((m) => Alarm.fromMap(m)).toList();
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await database;
    return db.update('alarms', alarm.toMap(),
        where: 'id = ?', whereArgs: [alarm.id]);
  }

  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

  // --- Holiday Cache ---

  Future<void> upsertHolidayCache(HolidayCache cache) async {
    final db = await database;
    await db.insert(
      'holiday_cache',
      cache.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HolidayCache?> getHolidayCache(int year) async {
    final db = await database;
    final maps = await db.query('holiday_cache',
        where: 'year = ?', whereArgs: [year]);
    if (maps.isEmpty) return null;
    return HolidayCache.fromMap(maps.first);
  }
}
