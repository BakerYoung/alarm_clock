import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class RingtoneService {
  static const builtinPrefix = 'builtin:';
  static const recordingPrefix = 'recording:';

  static List<String> get builtinRingtones => const [
        '${builtinPrefix}清晨阳光',
        '${builtinPrefix}鸟鸣山谷',
        '${builtinPrefix}海浪轻拍',
        '${builtinPrefix}城市黎明',
        '${builtinPrefix}森林微光',
      ];

  static Future<Directory> get _ringtoneDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/ringtones');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> get _recordingDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String?> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final sourcePath = file.path;
    if (sourcePath == null) return null;

    final destDir = await _ringtoneDir;
    final destPath = '${destDir.path}/${file.name}';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  static Future<List<String>> importedFiles() async {
    final dir = await _ringtoneDir;
    final files = dir.listSync().whereType<File>().toList();
    return files.map((f) => f.path).toList();
  }

  static Future<List<String>> recordingFiles() async {
    final dir = await _recordingDir;
    final files = dir.listSync().whereType<File>().toList();
    return files.map((f) => f.path).toList();
  }

  static String displayName(String path) {
    if (path.startsWith(builtinPrefix)) {
      return path.substring(builtinPrefix.length);
    }
    if (path.startsWith(recordingPrefix)) {
      return '录音 ${path.substring(recordingPrefix.length)}';
    }
    return p.basename(path);
  }

  static Future<void> deleteFile(String path) async {
    if (path.startsWith(builtinPrefix)) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
