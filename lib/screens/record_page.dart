import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  double _amplitude = 0;

  Future<void> _startRecording() async {
    final path = await AudioService.startRecording();
    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('麦克风权限未授权')),
        );
      }
      return;
    }
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
      if (_seconds >= 60) _stopRecording();
    });
    AudioService.amplitude.listen((amp) {
      setState(() => _amplitude = amp.current);
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await AudioService.stopRecording();
    if (path != null && mounted) {
      Navigator.pop(context);
    }
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('录制铃声')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            const Text('最长 60 秒', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.grey,
                  width: 3,
                ),
                color: _isRecording
                    ? Colors.red.withValues(alpha: 0.1 + _amplitude * 0.5)
                    : Colors.grey.shade200,
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: _isRecording ? Colors.red : null,
              ),
              child: Text(_isRecording ? '停止录制' : '开始录制',
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
