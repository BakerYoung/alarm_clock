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

  Alarm({
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
