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
