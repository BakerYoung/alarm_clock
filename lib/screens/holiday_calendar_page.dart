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
