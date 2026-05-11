import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/database_service.dart';
import '../services/alarm_scheduler.dart';
import '../engine/alarm_engine.dart';
import '../services/holiday_service.dart';
import 'alarm_edit_page.dart';
import 'holiday_calendar_page.dart';
import 'ringtone_manage_page.dart';
import 'settings_page.dart';
import '../widgets/alarm_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  late final HolidayService _holidayService;
  List<Alarm> _alarms = [];
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _holidayService = HolidayService(_db);
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
