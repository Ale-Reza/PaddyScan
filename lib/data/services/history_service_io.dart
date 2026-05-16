import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> _historyDir() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}/history_images');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Saves bytes to the file system. Returns the absolute path or null.
Future<String?> saveImageFile(List<int> bytes, String id) async {
  try {
    final dir = await _historyDir();
    final file = File('${dir.path}/history_$id.jpg');
    await file.writeAsBytes(bytes, flush: true);
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Deletes the image file at [path]. No-op if null or missing.
Future<void> deleteImageFile(String? path) async {
  if (path == null) return;
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
