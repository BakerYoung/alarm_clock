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
