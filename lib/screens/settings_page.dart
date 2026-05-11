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
