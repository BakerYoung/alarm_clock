// Web stub — file system operations are not available in browsers.
// The core alarm functionality (database, holiday fetching, UI) still works.

class FileHelper {
  static Future<bool> dirExists(String path) async => false;

  static Future<void> createDir(String path) async {}

  static Future<List<String>> listDir(String path) async => [];

  static Future<void> copyFile(String source, String dest) async {}

  static Future<bool> fileExists(String path) async => false;

  static Future<void> deleteFile(String path) async {}
}
