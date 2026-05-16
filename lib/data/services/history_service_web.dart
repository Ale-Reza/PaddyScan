// Web stub — file system operations are no-ops on web.
// Actual web image storage is handled via SharedPreferences in HistoryService.

Future<String?> saveImageFile(List<int> bytes, String id) async => null;

Future<void> deleteImageFile(String? path) async {}
