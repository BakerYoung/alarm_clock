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
