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
