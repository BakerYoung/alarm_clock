Future<String> getAppDocumentsDir() async {
  // On web, use a virtual path — actual storage goes through IndexedDB (sqflite_web)
  return '/app_data';
}
