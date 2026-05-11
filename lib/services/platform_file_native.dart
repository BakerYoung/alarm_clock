import 'dart:io';

class FileHelper {
  static Future<bool> dirExists(String path) async {
    return Directory(path).exists();
  }

  static Future<void> createDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<List<String>> listDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().map((f) => f.path).toList();
  }

  static Future<void> copyFile(String source, String dest) async {
    await File(source).copy(dest);
  }

  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  static Future<void> deleteFile(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
