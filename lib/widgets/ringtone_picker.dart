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
