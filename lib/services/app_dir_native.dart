import 'package:path_provider/path_provider.dart';

Future<String> getAppDocumentsDir() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}
