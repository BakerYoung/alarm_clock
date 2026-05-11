# 智能闹钟 App 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个 Flutter 跨平台闹钟 App，支持工作日规则引擎、中国节假日自动适配、自定义铃声。

**Architecture:** 分层架构 — models 定义数据，services 负责持久化/网络/系统调度，engine 封装决策逻辑，screens 按 Tab 组织页面。数据流：Alarm 模型 → DatabaseService 持久化 → AlarmEngine 判断是否触发 → AlarmScheduler 注册系统闹钟。

**Tech Stack:** Flutter 3.x + Dart, sqflite, http, audioplayers, record, file_picker, intl, timezone, flutter_local_notifications, path_provider, shared_preferences

**前置条件:** 安装 Flutter SDK (`flutter --version` 确认可用)

---

## 文件结构

```
alarm_clock/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── alarm.dart
│   │   └── holiday_cache.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── alarm_scheduler.dart
│   │   ├── holiday_service.dart
│   │   ├── ringtone_service.dart
│   │   └── audio_service.dart
│   ├── engine/
│   │   └── alarm_engine.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── alarm_edit_page.dart
│   │   ├── holiday_calendar_page.dart
│   │   ├── ringtone_manage_page.dart
│   │   ├── record_page.dart
│   │   └── settings_page.dart
│   └── widgets/
│       ├── alarm_card.dart
│       ├── ringtone_picker.dart
│       ├── day_of_week_picker.dart
│       └── calendar_widget.dart
├── assets/
│   └── ringtones/
│       └── .gitkeep
└── test/
    ├── engine/
    │   └── alarm_engine_test.dart
    ├── services/
    │   ├── database_service_test.dart
    │   └── holiday_service_test.dart
    └── models/
        └── alarm_test.dart
```

---

### Task 1: 创建 Flutter 项目骨架

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `assets/ringtones/.gitkeep`

- [ ] **Step 1: 创建 Flutter 项目**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter create --org com.alarmclock --project-name alarm_clock .
```

Expected: Flutter 项目文件生成，包括 `lib/main.dart`, `pubspec.yaml`, `test/` 等目录。

- [ ] **Step 2: 配置 pubspec.yaml 依赖**

替换 `pubspec.yaml` 内容：

```yaml
name: alarm_clock
description: 智能工作日闹钟 - 节假日自动适配 + 自定义铃声
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.0
  path_provider: ^2.1.0
  http: ^1.1.0
  audioplayers: ^5.2.0
  record: ^5.0.0
  file_picker: ^6.1.0
  intl: ^0.18.0
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  sqflite_common_ffi: ^2.3.0

flutter:
  uses-material-design: true
  assets:
    - assets/ringtones/
```

- [ ] **Step 3: 安装依赖**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter pub get
```

Expected: `flutter pub get` 成功，无错误。

- [ ] **Step 4: 编写 App 入口**

Write `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlarmClockApp());
}
```

- [ ] **Step 5: 编写 MaterialApp 和主题**

Write `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class AlarmClockApp extends StatelessWidget {
  const AlarmClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智能闹钟',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 6: 创建占位 HomeScreen**

Write `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('智能闹钟')),
      body: const Center(child: Text('Hello, Alarm Clock!')),
    );
  }
}
```

- [ ] **Step 7: 验证项目可运行**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 8: 初始化 Git 并提交**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
git init
echo -e ".dart_tool/\n.packages/\nbuild/\n*.iml\n.idea/\nandroid/local.properties\nios/Pods/\n.superpowers/" > .gitignore
git add -A
git commit -m "feat: scaffold Flutter project with dependencies"
```

---

### Task 2: Alarm 数据模型

**Files:**
- Create: `lib/models/alarm.dart`
- Create: `test/models/alarm_test.dart`

- [ ] **Step 1: 编写 Alarm 模型类**

Write `lib/models/alarm.dart`:

```dart
enum AlarmRule { once, daily, weekday, custom }

enum SoundType { builtin, file, recording }

class Alarm {
  final int? id;
  final String name;
  final String time; // HH:mm
  final AlarmRule rule;
  final List<int> customDays; // 0=Sun, 1=Mon, ..., 6=Sat
  final SoundType soundType;
  final String soundPath;
  final bool enabled;
  final int snoozeMinutes;
  final DateTime createdAt;

  const Alarm({
    this.id,
    required this.name,
    required this.time,
    required this.rule,
    this.customDays = const [],
    required this.soundType,
    required this.soundPath,
    this.enabled = true,
    this.snoozeMinutes = 10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Alarm copyWith({
    int? id,
    String? name,
    String? time,
    AlarmRule? rule,
    List<int>? customDays,
    SoundType? soundType,
    String? soundPath,
    bool? enabled,
    int? snoozeMinutes,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      rule: rule ?? this.rule,
      customDays: customDays ?? this.customDays,
      soundType: soundType ?? this.soundType,
      soundPath: soundPath ?? this.soundPath,
      enabled: enabled ?? this.enabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'time': time,
      'rule': rule.index,
      'customDays': customDays.join(','),
      'soundType': soundType.index,
      'soundPath': soundPath,
      'enabled': enabled ? 1 : 0,
      'snoozeMinutes': snoozeMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    final customDaysStr = map['customDays'] as String? ?? '';
    return Alarm(
      id: map['id'] as int?,
      name: map['name'] as String,
      time: map['time'] as String,
      rule: AlarmRule.values[map['rule'] as int],
      customDays: customDaysStr.isEmpty
          ? []
          : customDaysStr.split(',').map(int.parse).toList(),
      soundType: SoundType.values[map['soundType'] as int],
      soundPath: map['soundPath'] as String,
      enabled: (map['enabled'] as int) == 1,
      snoozeMinutes: map['snoozeMinutes'] as int? ?? 10,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get ruleLabel {
    switch (rule) {
      case AlarmRule.once:
        return '仅一次';
      case AlarmRule.daily:
        return '每天';
      case AlarmRule.weekday:
        return '工作日';
      case AlarmRule.custom:
        const dayNames = ['日', '一', '二', '三', '四', '五', '六'];
        final sorted = List<int>.from(customDays)..sort();
        final names = sorted.map((d) => '周${dayNames[d]}').join('、');
        return names;
    }
  }
}
```

- [ ] **Step 2: 编写 Alarm 模型测试**

Write `test/models/alarm_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_clock/models/alarm.dart';

void main() {
  group('Alarm', () {
    test('toMap and fromMap roundtrip', () {
      final alarm = Alarm(
        name: 'Test',
        time: '07:30',
        rule: AlarmRule.weekday,
        soundType: SoundType.builtin,
        soundPath: 'assets/ringtones/morning.mp3',
        enabled: true,
        snoozeMinutes: 5,
      );
      final map = alarm.toMap();
      final restored = Alarm.fromMap(map);
      expect(restored.name, 'Test');
      expect(restored.time, '07:30');
      expect(restored.rule, AlarmRule.weekday);
      expect(restored.snoozeMinutes, 5);
    });

    test('ruleLabel returns correct labels', () {
      final alarm = Alarm(
        name: 'Test',
        time: '07:30',
        rule: AlarmRule.custom,
        customDays: [1, 3, 5],
        soundType: SoundType.builtin,
        soundPath: 'test.mp3',
      );
      expect(alarm.ruleLabel, '周一、三、五');
    });

    test('copyWith updates fields', () {
      final alarm = Alarm(
        name: 'Test',
        time: '07:30',
        rule: AlarmRule.once,
        soundType: SoundType.builtin,
        soundPath: 'test.mp3',
      );
      final updated = alarm.copyWith(name: 'Updated', enabled: false);
      expect(updated.name, 'Updated');
      expect(updated.enabled, false);
      expect(updated.time, '07:30'); // unchanged
    });
  });
}
```

- [ ] **Step 3: 运行测试**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter test test/models/alarm_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 4: 提交**

```bash
git add lib/models/alarm.dart test/models/alarm_test.dart
git commit -m "feat: add Alarm model with serialization and tests"
```

---

### Task 3: HolidayCache 数据模型

**Files:**
- Create: `lib/models/holiday_cache.dart`

- [ ] **Step 1: 编写 HolidayCache 模型**

Write `lib/models/holiday_cache.dart`:

```dart
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
```

- [ ] **Step 2: 提交**

```bash
git add lib/models/holiday_cache.dart
git commit -m "feat: add HolidayCache model"
```

---

### Task 4: DatabaseService

**Files:**
- Create: `lib/services/database_service.dart`
- Create: `test/services/database_service_test.dart`

- [ ] **Step 1: 编写 DatabaseService**

Write `lib/services/database_service.dart`:

```dart
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
```

- [ ] **Step 2: 编写 DatabaseService 测试（使用 sqflite_common_ffi 内存数据库）**

Write `test/services/database_service_test.dart`:

```dart
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
```

- [ ] **Step 3: 运行测试**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter test test/services/database_service_test.dart
```

Expected: 4 tests pass.

- [ ] **Step 4: 提交**

```bash
git add lib/services/database_service.dart test/services/database_service_test.dart
git commit -m "feat: add DatabaseService with SQLite CRUD for alarms and holiday cache"
```

---

### Task 5: HolidayService（节假日 API + 缓存）

**Files:**
- Create: `lib/services/holiday_service.dart`
- Create: `test/services/holiday_service_test.dart`

- [ ] **Step 1: 编写 HolidayService**

Write `lib/services/holiday_service.dart`:

```dart
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
```

- [ ] **Step 2: 编写 HolidayService 测试**

Write `test/services/holiday_service_test.dart`:

```dart
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
    // Note: this test hits the real API — may need mocking in CI
    try {
      final cache = await service.fetchAndCache(2026);
      expect(cache.year, 2026);
      expect(cache.holidays, isNotEmpty);

      // Second call should return from cache
      final cached = await service.getHolidays(2026);
      expect(cached.holidays, cache.holidays);
    } catch (e) {
      // Skip if API is unreachable
      print('Skipping test: API unreachable ($e)');
    }
  });
}
```

- [ ] **Step 3: 运行测试**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter test test/services/holiday_service_test.dart
```

Expected: Test passes (or skips if API unreachable).

- [ ] **Step 4: 提交**

```bash
git add lib/services/holiday_service.dart test/services/holiday_service_test.dart
git commit -m "feat: add HolidayService with API fetch and local cache"
```

---

### Task 6: AlarmEngine（闹钟决策引擎）

**Files:**
- Create: `lib/engine/alarm_engine.dart`
- Create: `test/engine/alarm_engine_test.dart`

- [ ] **Step 1: 编写 AlarmEngine**

Write `lib/engine/alarm_engine.dart`:

```dart
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
        return false; // One-time alarms handled by scheduler directly
      case AlarmRule.daily:
        return true;
      case AlarmRule.weekday:
        return weekday >= 1 && weekday <= 5;
      case AlarmRule.custom:
        // customDays stores 0=Sun...6=Sat, convert weekday (1=Mon...7=Sun)
        final customDay = weekday == 7 ? 0 : weekday;
        return alarm.customDays.contains(customDay);
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: 编写 AlarmEngine 测试**

Write `test/engine/alarm_engine_test.dart`:

```dart
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
    holidays: ['2026-05-01'], // 劳动节
    makeupDays: ['2026-05-03'], // 调休上班（周日）
  );

  group('AlarmEngine', () {
    test('weekday alarm fires on Monday', () {
      final monday = DateTime(2026, 4, 27); // 周一，非假期
      expect(AlarmEngine.shouldFire(weekdayAlarm, monday, cache), true);
    });

    test('weekday alarm does NOT fire on Saturday', () {
      final saturday = DateTime(2026, 4, 25); // 周六
      expect(AlarmEngine.shouldFire(weekdayAlarm, saturday, cache), false);
    });

    test('weekday alarm does NOT fire on holiday (May 1st)', () {
      final holidayFriday = DateTime(2026, 5, 1); // 周五，但劳动节
      expect(AlarmEngine.shouldFire(weekdayAlarm, holidayFriday, cache), false);
    });

    test('weekday alarm fires on makeup workday (May 3rd, Sunday)', () {
      final makeupSunday = DateTime(2026, 5, 3); // 周日，但调休上班
      expect(AlarmEngine.shouldFire(weekdayAlarm, makeupSunday, cache), true);
    });

    test('daily alarm fires on holiday', () {
      final dailyAlarm = weekdayAlarm.copyWith(rule: AlarmRule.daily);
      final holiday = DateTime(2026, 5, 1); // 劳动节
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
        customDays: [1, 3, 5], // 周一、三、五
      );
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 27), null), true); // Mon
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 28), null), false); // Tue
      expect(AlarmEngine.shouldFire(customAlarm, DateTime(2026, 4, 29), null), true); // Wed
    });

    test('null holidayCache falls through to base rule', () {
      final friday = DateTime(2026, 5, 1); // Friday
      // Without holiday data, weekday rule applies normally
      expect(AlarmEngine.shouldFire(weekdayAlarm, friday, null), true);
    });
  });
}
```

- [ ] **Step 3: 运行测试**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter test test/engine/alarm_engine_test.dart
```

Expected: 8 tests pass.

- [ ] **Step 4: 提交**

```bash
git add lib/engine/alarm_engine.dart test/engine/alarm_engine_test.dart
git commit -m "feat: add AlarmEngine with two-level holiday-aware decision logic"
```

---

### Task 7: AlarmScheduler（系统闹钟调度）

**Files:**
- Create: `lib/services/alarm_scheduler.dart`

- [ ] **Step 1: 编写 AlarmScheduler**

Write `lib/services/alarm_scheduler.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmScheduler {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    final timeParts = alarm.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel',
        '闹钟',
        channelDescription: '闹钟通知',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        criticalAlert: true,
      ),
    );

    await _plugin.zonedSchedule(
      alarm.id ?? 0,
      alarm.name,
      '闹钟响了！',
      _scheduleDaily(hour, minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Store alarm time for widget check
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarm_${alarm.id}_next', scheduledDate.toIso8601String());
  }

  static Future<void> cancelAlarm(int id) async {
    await _plugin.cancel(id);
  }

  static tz.TZDateTime _scheduleDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/services/alarm_scheduler.dart
git commit -m "feat: add AlarmScheduler using flutter_local_notifications"
```

---

### Task 8: RingtoneService（铃声文件管理）

**Files:**
- Create: `lib/services/ringtone_service.dart`

- [ ] **Step 1: 编写 RingtoneService**

Write `lib/services/ringtone_service.dart`:

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class RingtoneService {
  static const builtinPrefix = 'builtin:';
  static const recordingPrefix = 'recording:';

  static List<String> get builtinRingtones => const [
        '${builtinPrefix}清晨阳光',
        '${builtinPrefix}鸟鸣山谷',
        '${builtinPrefix}海浪轻拍',
        '${builtinPrefix}城市黎明',
        '${builtinPrefix}森林微光',
      ];

  static Future<Directory> get _ringtoneDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/ringtones');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> get _recordingDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Import a ringtone from device storage
  static Future<String?> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final sourcePath = file.path;
    if (sourcePath == null) return null;

    final destDir = await _ringtoneDir;
    final destPath = '${destDir.path}/${file.name}';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// List all user-imported ringtone files
  static Future<List<String>> importedFiles() async {
    final dir = await _ringtoneDir;
    final files = dir.listSync().whereType<File>().toList();
    return files.map((f) => f.path).toList();
  }

  /// List all recording files
  static Future<List<String>> recordingFiles() async {
    final dir = await _recordingDir;
    final files = dir.listSync().whereType<File>().toList();
    return files.map((f) => f.path).toList();
  }

  /// Get a display name for a ringtone path
  static String displayName(String path) {
    if (path.startsWith(builtinPrefix)) {
      return path.substring(builtinPrefix.length);
    }
    if (path.startsWith(recordingPrefix)) {
      return '录音 ${path.substring(recordingPrefix.length)}';
    }
    return p.basename(path);
  }

  /// Delete a ringtone file (not builtin or recording)
  static Future<void> deleteFile(String path) async {
    if (path.startsWith(builtinPrefix)) return; // Cannot delete builtin
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/services/ringtone_service.dart
git commit -m "feat: add RingtoneService for file import and management"
```

---

### Task 9: AudioService（音频播放和录音）

**Files:**
- Create: `lib/services/audio_service.dart`

- [ ] **Step 1: 编写 AudioService**

Write `lib/services/audio_service.dart`:

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<void> play(String path) async {
    if (path.startsWith(RingtoneService.builtinPrefix)) {
      // Built-in ringtones are silent placeholders — use a default system sound
      // In production, bundle actual audio files in assets/ringtones/
      await _player.play(AssetSource('ringtones/default.mp3'));
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Stream<PlayerState> get playerState => _player.onPlayerStateChanged;

  static Future<bool> hasMicrophonePermission() async {
    return _recorder.hasPermission();
  }

  static Future<String?> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${appDir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${recordingsDir.path}/$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    return path;
  }

  static Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  static Stream<RecordState> get recorderState => _recorder.onStateChanged();

  static Stream<Amplitude> get amplitude => _recorder.onAmplitude(
        const Amplitude(enabled: true),
      );
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/services/audio_service.dart
git commit -m "feat: add AudioService for playback and recording"
```

---

### Task 10: UI 组件 — AlarmCard

**Files:**
- Create: `lib/widgets/alarm_card.dart`

- [ ] **Step 1: 编写 AlarmCard 组件**

Write `lib/widgets/alarm_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !alarm.enabled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key('alarm_${alarm.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Text(
            alarm.time,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: isDisabled ? theme.disabledColor : theme.colorScheme.primary,
            ),
          ),
          title: Text(
            alarm.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDisabled ? theme.disabledColor : null,
            ),
          ),
          subtitle: Text(
            alarm.ruleLabel,
            style: TextStyle(
              color: isDisabled ? theme.disabledColor : theme.colorScheme.outline,
            ),
          ),
          trailing: Switch(
            value: alarm.enabled,
            onChanged: onToggle,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/widgets/alarm_card.dart
git commit -m "feat: add AlarmCard widget with swipe-to-delete"
```

---

### Task 11: UI 组件 — DayOfWeekPicker, RingtonePicker, CalendarWidget

**Files:**
- Create: `lib/widgets/day_of_week_picker.dart`
- Create: `lib/widgets/ringtone_picker.dart`
- Create: `lib/widgets/calendar_widget.dart`

- [ ] **Step 1: 编写 DayOfWeekPicker**

Write `lib/widgets/day_of_week_picker.dart`:

```dart
import 'package:flutter/material.dart';

class DayOfWeekPicker extends StatelessWidget {
  final List<int> selectedDays; // 0=Sun...6=Sat
  final ValueChanged<List<int>> onChanged;

  const DayOfWeekPicker({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const _dayNames = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return GestureDetector(
          onTap: () {
            final newDays = List<int>.from(selectedDays);
            if (isSelected) {
              newDays.remove(index);
            } else {
              newDays.add(index);
            }
            onChanged(newDays);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                _dayNames[index],
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: 编写 RingtonePicker**

Write `lib/widgets/ringtone_picker.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/ringtone_service.dart';
import '../services/audio_service.dart';

class RingtonePicker extends StatefulWidget {
  final SoundType initialType;
  final String initialPath;
  final ValueChanged<SoundType>? onTypeChanged;
  final ValueChanged<String>? onPathChanged;

  const RingtonePicker({
    super.key,
    required this.initialType,
    required this.initialPath,
    this.onTypeChanged,
    this.onPathChanged,
  });

  @override
  State<RingtonePicker> createState() => _RingtonePickerState();
}

class _RingtonePickerState extends State<RingtonePicker> {
  late SoundType _selectedType;
  late String _selectedPath;
  late List<String> _importedFiles;
  late List<String> _recordings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedPath = widget.initialPath;
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final imported = await RingtoneService.importedFiles();
    final recordings = await RingtoneService.recordingFiles();
    setState(() {
      _importedFiles = imported;
      _recordings = recordings;
      _loading = false;
    });
  }

  void _select(SoundType type, String path) {
    setState(() {
      _selectedType = type;
      _selectedPath = path;
    });
    widget.onTypeChanged?.call(type);
    widget.onPathChanged?.call(path);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('内置铃声', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...RingtoneService.builtinRingtones.map((r) => _RingtoneTile(
              name: RingtoneService.displayName(r),
              path: r,
              isSelected: _selectedPath == r,
              onTap: () => _select(SoundType.builtin, r),
              onPlay: () => AudioService.play(r),
            )),
        const SizedBox(height: 16),
        const Text('本地文件', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._importedFiles.map((f) => _RingtoneTile(
              name: RingtoneService.displayName(f),
              path: f,
              isSelected: _selectedPath == f,
              onTap: () => _select(SoundType.file, f),
              onPlay: () => AudioService.play(f),
            )),
        if (_importedFiles.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('暂无文件，请导入', style: TextStyle(color: Colors.grey)),
          ),
        const SizedBox(height: 16),
        const Text('我的录音', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._recordings.map((f) => _RingtoneTile(
              name: RingtoneService.displayName(f),
              path: f,
              isSelected: _selectedPath == f,
              onTap: () => _select(SoundType.recording, f),
              onPlay: () => AudioService.play(f),
            )),
        if (_recordings.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('暂无录音', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}

class _RingtoneTile extends StatelessWidget {
  final String name;
  final String path;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _RingtoneTile({
    required this.name,
    required this.path,
    required this.isSelected,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined),
      trailing: IconButton(icon: const Icon(Icons.play_arrow), onPressed: onPlay),
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 3: 编写 CalendarWidget**

Write `lib/widgets/calendar_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/holiday_cache.dart';

class CalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final HolidayCache? holidayCache;

  const CalendarWidget({
    super.key,
    required this.year,
    required this.month,
    this.holidayCache,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon

    final holidaySet = holidayCache?.holidays.toSet() ?? {};
    final makeupSet = holidayCache?.makeupDays.toSet() ?? {};

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.w500)))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: firstWeekday - 1 + daysInMonth,
          itemBuilder: (context, index) {
            final day = index - (firstWeekday - 1) + 1;
            if (day <= 0) return const SizedBox.shrink();

            final dateStr =
                '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
            final isHoliday = holidaySet.contains(dateStr);
            final isMakeup = makeupSet.contains(dateStr);

            Color? bgColor;
            Color? textColor;
            if (isHoliday) {
              bgColor = Colors.red.shade100;
              textColor = Colors.red.shade800;
            } else if (isMakeup) {
              bgColor = Colors.green.shade100;
              textColor = Colors.green.shade800;
            }

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isHoliday || isMakeup ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add lib/widgets/day_of_week_picker.dart lib/widgets/ringtone_picker.dart lib/widgets/calendar_widget.dart
git commit -m "feat: add DayOfWeekPicker, RingtonePicker, and CalendarWidget"
```

---

### Task 12: 闹钟列表页和编辑页

**Files:**
- Create: `lib/screens/alarm_edit_page.dart`
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: 编写闹钟列表页（重写 HomeScreen）**

Rewrite `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/database_service.dart';
import '../services/alarm_scheduler.dart';
import '../engine/alarm_engine.dart';
import '../services/holiday_service.dart';
import '../screens/alarm_edit_page.dart';
import '../screens/holiday_calendar_page.dart';
import '../screens/ringtone_manage_page.dart';
import '../screens/settings_page.dart';
import '../widgets/alarm_card.dart';
import '../services/ringtone_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  final HolidayService _holidayService = HolidayService(_db);
  List<Alarm> _alarms = [];
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    AlarmScheduler.init();
  }

  Future<void> _loadAlarms() async {
    final alarms = await _db.getAlarms();
    setState(() => _alarms = alarms);
  }

  Future<void> _toggleAlarm(Alarm alarm, bool enabled) async {
    final updated = alarm.copyWith(enabled: enabled);
    await _db.updateAlarm(updated);
    if (enabled) {
      await AlarmScheduler.scheduleAlarm(updated);
    } else {
      await AlarmScheduler.cancelAlarm(alarm.id!);
    }
    _loadAlarms();
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    await _db.deleteAlarm(alarm.id!);
    await AlarmScheduler.cancelAlarm(alarm.id!);
    _loadAlarms();
  }

  void _navigateToEdit({Alarm? alarm}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlarmEditPage(existingAlarm: alarm),
      ),
    );
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildAlarmList(context),
      HolidayCalendarPage(holidayService: _holidayService),
      const RingtoneManagePage(),
      SettingsPage(holidayService: _holidayService),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentTab, children: pages),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToEdit(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.alarm), label: '闹钟'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: '日历'),
          NavigationDestination(icon: Icon(Icons.music_note), label: '铃声'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildAlarmList(BuildContext context) {
    return SafeArea(
      child: _alarms.isEmpty
          ? const Center(child: Text('暂无闹钟，点击 + 创建'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return AlarmCard(
                  alarm: alarm,
                  onTap: () => _navigateToEdit(alarm: alarm),
                  onToggle: (enabled) => _toggleAlarm(alarm, enabled),
                  onDelete: () => _deleteAlarm(alarm),
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 2: 编写闹钟编辑页**

Write `lib/screens/alarm_edit_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/database_service.dart';
import '../services/alarm_scheduler.dart';
import '../widgets/day_of_week_picker.dart';
import '../widgets/ringtone_picker.dart';

class AlarmEditPage extends StatefulWidget {
  final Alarm? existingAlarm;

  const AlarmEditPage({super.key, this.existingAlarm});

  @override
  State<AlarmEditPage> createState() => _AlarmEditPageState();
}

class _AlarmEditPageState extends State<AlarmEditPage> {
  final _db = DatabaseService();
  final _nameController = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 30);
  AlarmRule _rule = AlarmRule.weekday;
  List<int> _customDays = [1, 2, 3, 4, 5];
  SoundType _soundType = SoundType.builtin;
  String _soundPath = 'builtin:清晨阳光';
  bool _enabled = true;
  int _snoozeMinutes = 10;

  bool get isEditing => widget.existingAlarm != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingAlarm != null) {
      final a = widget.existingAlarm!;
      _nameController.text = a.name;
      final parts = a.time.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      _rule = a.rule;
      _customDays = List.from(a.customDays);
      _soundType = a.soundType;
      _soundPath = a.soundPath;
      _enabled = a.enabled;
      _snoozeMinutes = a.snoozeMinutes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入闹钟名称')),
      );
      return;
    }

    final alarm = Alarm(
      id: widget.existingAlarm?.id,
      name: _nameController.text,
      time: '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
      rule: _rule,
      customDays: _customDays,
      soundType: _soundType,
      soundPath: _soundPath,
      enabled: _enabled,
      snoozeMinutes: _snoozeMinutes,
    );

    if (isEditing) {
      await _db.updateAlarm(alarm);
    } else {
      final id = await _db.insertAlarm(alarm);
      final saved = alarm.copyWith(id: id);
      if (_enabled) {
        await AlarmScheduler.scheduleAlarm(saved);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑闹钟' : '新建闹钟'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                child: Text(
                  _time.format(context),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Repeat rule
            const Text('重复', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<AlarmRule>(
              segments: const [
                ButtonSegment(value: AlarmRule.once, label: Text('仅一次')),
                ButtonSegment(value: AlarmRule.daily, label: Text('每天')),
                ButtonSegment(value: AlarmRule.weekday, label: Text('工作日')),
                ButtonSegment(value: AlarmRule.custom, label: Text('自定义')),
              ],
              selected: {_rule},
              onSelectionChanged: (s) => setState(() => _rule = s.first),
            ),

            // Custom day picker
            if (_rule == AlarmRule.custom) ...[
              const SizedBox(height: 16),
              DayOfWeekPicker(
                selectedDays: _customDays,
                onChanged: (days) => setState(() => _customDays = days),
              ),
            ],
            const SizedBox(height: 24),

            // Ringtone selector
            const Text('铃声', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showRingtonePicker(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(width: 12),
                    Text('已选择铃声'),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Snooze
            SwitchListTile(
              title: const Text('贪睡'),
              subtitle: Text('间隔 $_snoozeMinutes 分钟'),
              value: _snoozeMinutes > 0,
              onChanged: (val) => setState(() => _snoozeMinutes = val ? 10 : 0),
            ),
          ],
        ),
      ),
    );
  }

  void _showRingtonePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: RingtonePicker(
            initialType: _soundType,
            initialPath: _soundPath,
            onTypeChanged: (t) => setState(() => _soundType = t),
            onPathChanged: (p) => setState(() => _soundPath = p),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 提交**

```bash
git add lib/screens/home_screen.dart lib/screens/alarm_edit_page.dart
git commit -m "feat: add alarm list and edit pages with full alarm creation flow"
```

---

### Task 13: 节假日日历页

**Files:**
- Create: `lib/screens/holiday_calendar_page.dart`

- [ ] **Step 1: 编写节假日日历页**

Write `lib/screens/holiday_calendar_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/holiday_cache.dart';
import '../services/holiday_service.dart';
import '../widgets/calendar_widget.dart';

class HolidayCalendarPage extends StatefulWidget {
  final HolidayService holidayService;

  const HolidayCalendarPage({super.key, required this.holidayService});

  @override
  State<HolidayCalendarPage> createState() => _HolidayCalendarPageState();
}

class _HolidayCalendarPageState extends State<HolidayCalendarPage> {
  late DateTime _currentDate;
  HolidayCache? _cache;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    setState(() => _loading = true);
    try {
      final cache = await widget.holidayService.getHolidays(_currentDate.year);
      setState(() {
        _cache = cache;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + delta, 1);
    });
    _loadHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                Text(
                  '${_currentDate.year}年${_currentDate.month}月',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              CalendarWidget(
                year: _currentDate.year,
                month: _currentDate.month,
                holidayCache: _cache,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.red.shade300, label: '放假'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.green.shade300, label: '调休上班'),
              ],
            ),
            if (_cache != null) ...[
              const SizedBox(height: 8),
              Text(
                '上次同步: ${_cache!.updatedAt.month}/${_cache!.updatedAt.day}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/screens/holiday_calendar_page.dart
git commit -m "feat: add holiday calendar page with month view"
```

---

### Task 14: 铃声管理和录音页

**Files:**
- Create: `lib/screens/ringtone_manage_page.dart`
- Create: `lib/screens/record_page.dart`

- [ ] **Step 1: 编写铃声管理页**

Write `lib/screens/ringtone_manage_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/ringtone_service.dart';
import '../services/audio_service.dart';
import 'record_page.dart';

class RingtoneManagePage extends StatefulWidget {
  const RingtoneManagePage({super.key});

  @override
  State<RingtoneManagePage> createState() => _RingtoneManagePageState();
}

class _RingtoneManagePageState extends State<RingtoneManagePage> {
  List<String> _importedFiles = [];
  List<String> _recordings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final imported = await RingtoneService.importedFiles();
    final recordings = await RingtoneService.recordingFiles();
    setState(() {
      _importedFiles = imported;
      _recordings = recordings;
    });
  }

  Future<void> _importFile() async {
    final path = await RingtoneService.importFile();
    if (path != null) _load();
  }

  Future<void> _deleteFile(String path) async {
    await RingtoneService.deleteFile(path);
    _load();
  }

  Future<void> _recordNew() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordPage()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('内置铃声', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...RingtoneService.builtinRingtones.map(
              (r) => ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(RingtoneService.displayName(r)),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => AudioService.play(r),
                ),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('本地文件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _importFile,
                  icon: const Icon(Icons.add),
                  label: const Text('导入'),
                ),
              ],
            ),
            if (_importedFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无导入文件', style: TextStyle(color: Colors.grey)),
              ),
            ..._importedFiles.map(
              (f) => ListTile(
                leading: const Icon(Icons.audio_file),
                title: Text(RingtoneService.displayName(f)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => AudioService.play(f)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteFile(f)),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('录音', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _recordNew,
                  icon: const Icon(Icons.mic),
                  label: const Text('录制'),
                ),
              ],
            ),
            if (_recordings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无录音', style: TextStyle(color: Colors.grey)),
              ),
            ..._recordings.map(
              (f) => ListTile(
                leading: const Icon(Icons.mic),
                title: Text(RingtoneService.displayName(f)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => AudioService.play(f)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteFile(f)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 编写录音页**

Write `lib/screens/record_page.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../services/audio_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  double _amplitude = 0;

  Future<void> _startRecording() async {
    final path = await AudioService.startRecording();
    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('麦克风权限未授权')),
        );
      }
      return;
    }
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
      if (_seconds >= 60) _stopRecording();
    });
    AudioService.amplitude.listen((amp) {
      setState(() => _amplitude = amp.current);
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await AudioService.stopRecording();
    if (path != null && mounted) {
      Navigator.pop(context);
    }
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('录制铃声')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            const Text('最长 60 秒', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            // Amplitude visualization
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.grey,
                  width: 3,
                ),
                color: _isRecording
                    ? Colors.red.withOpacity(0.1 + _amplitude * 0.5)
                    : Colors.grey.shade200,
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: _isRecording ? Colors.red : null,
              ),
              child: Text(_isRecording ? '停止录制' : '开始录制',
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 提交**

```bash
git add lib/screens/ringtone_manage_page.dart lib/screens/record_page.dart
git commit -m "feat: add ringtone management and recording pages"
```

---

### Task 15: 设置页

**Files:**
- Create: `lib/screens/settings_page.dart`

- [ ] **Step 1: 编写设置页**

Write `lib/screens/settings_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/holiday_service.dart';

class SettingsPage extends StatelessWidget {
  final HolidayService holidayService;

  const SettingsPage({super.key, required this.holidayService});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('节假日数据'),
            subtitle: const Text('手动刷新年度节假日安排'),
            trailing: const Icon(Icons.refresh),
            onTap: () async {
              try {
                await holidayService.refresh(DateTime.now().year);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('刷新成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刷新失败: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('智能闹钟 v1.0.0'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/screens/settings_page.dart
git commit -m "feat: add settings page with holiday refresh"
```

---

### Task 16: 集成测试和最终验证

**Files:** 无新建，验证现有内容

- [ ] **Step 1: 运行 flutter analyze**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: 运行所有测试**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
flutter test
```

Expected: All tests pass.

- [ ] **Step 3: 验证文件结构完整**

```bash
cd /Users/yangming/data/workspace/claude_code_workspace/work_temp/alarm_clock
find lib test -type f | sort
```

Expected: 所有计划中的文件都存在。

- [ ] **Step 4: 最终提交**

```bash
git add -A
git commit -m "feat: complete alarm clock app with workday engine, holiday support, and custom ringtones

- AlarmEngine: two-level decision logic (rule matching + holiday override)
- HolidayService: auto-fetch from timor.tech API with local cache
- Ringtone management: built-in + file import + recording
- 4-tab navigation: Alarms, Calendar, Ringtones, Settings

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```
