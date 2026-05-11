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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
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
            if (_rule == AlarmRule.custom) ...[
              const SizedBox(height: 16),
              DayOfWeekPicker(
                selectedDays: _customDays,
                onChanged: (days) => setState(() => _customDays = days),
              ),
            ],
            const SizedBox(height: 24),
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
                child: const Row(
                  children: [
                    Icon(Icons.music_note),
                    SizedBox(width: 12),
                    Text('选择铃声'),
                    Spacer(),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
