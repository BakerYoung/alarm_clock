import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'ringtone_service.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<void> play(String path) async {
    if (path.startsWith(RingtoneService.builtinPrefix)) {
      await _player.play(AssetSource('ringtones/default.mp3'));
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Stream<PlayerState> get playerState => _player.onPlayerStateChanged;

  static Future<bool> hasMicrophonePermission() async {
    return _recorder.hasPermission();
  }

  static Future<String?> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${appDir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${recordingsDir.path}/$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    return path;
  }

  static Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  static Stream<RecordState> get recorderState => _recorder.onStateChanged();

  static Stream<Amplitude> get amplitude => _recorder.onAmplitudeChanged(
        const Duration(milliseconds: 100),
      );
}
