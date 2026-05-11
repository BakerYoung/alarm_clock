import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'platform_file_native.dart' if (dart.library.html) 'platform_file_web.dart';
import 'app_dir_native.dart' if (dart.library.html) 'app_dir_web.dart';

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

  static Future<String> get _ringtoneDirPath async {
    final appDir = await getAppDocumentsDir();
    return '$appDir/ringtones';
  }

  static Future<String> get _recordingDirPath async {
    final appDir = await getAppDocumentsDir();
    return '$appDir/recordings';
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

    final destDir = await _ringtoneDirPath;
    await FileHelper.createDir(destDir);
    final destPath = '$destDir/${file.name}';
    await FileHelper.copyFile(sourcePath, destPath);
    return destPath;
  }

  static Future<List<String>> importedFiles() async {
    final dir = await _ringtoneDirPath;
    return FileHelper.listDir(dir);
  }

  static Future<List<String>> recordingFiles() async {
    final dir = await _recordingDirPath;
    return FileHelper.listDir(dir);
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
    await FileHelper.deleteFile(path);
  }
}
