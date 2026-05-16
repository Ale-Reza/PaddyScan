import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';

// dart:io is only available on native platforms
import 'history_service_io.dart'
    if (dart.library.html) 'history_service_web.dart' as platform;

class HistoryService {
  static const _key = 'scan_history';
  static const _maxEntries = 50;
  // Prefix used to identify web-stored image keys vs file paths
  static const _webPrefix = 'web:';

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Returns all saved scans, newest first.
  Future<List<ScanHistory>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => ScanHistory.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Saves a scan entry. Keeps only the latest [_maxEntries] entries.
  Future<void> save(ScanHistory entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) {
      for (int i = 0; i < raw.length - _maxEntries; i++) {
        final map = jsonDecode(raw[i]) as Map<String, dynamic>;
        await _deleteImage(map['imagePath'] as String?, prefs);
        await _deleteImage(map['processedImagePath'] as String?, prefs);
      }
      raw.removeRange(0, raw.length - _maxEntries);
    }
    await prefs.setStringList(_key, raw);
  }

  /// Updates AI response and/or processed image path for an existing entry.
  Future<void> updateEntry(String id,
      {String? aiResponse, String? processedImagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final updated = raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      if (map['id'] == id) {
        if (aiResponse != null) map['aiResponse'] = aiResponse;
        if (processedImagePath != null) {
          map['processedImagePath'] = processedImagePath;
        }
      }
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_key, updated);
  }

  // ── Image storage ───────────────────────────────────────────────────────────

  /// Saves image bytes. Returns:
  /// - On native: absolute file path  (e.g. /data/.../history_images/history_id.jpg)
  /// - On web:    "web:<prefs-key>"   (e.g. web:hist_img_id)
  /// Returns null if saving fails or bytes are empty.
  Future<String?> saveImage(List<int> bytes, String id) async {
    if (bytes.isEmpty) return null;
    if (kIsWeb) {
      return _saveImageWeb(bytes, id);
    } else {
      return platform.saveImageFile(bytes, id);
    }
  }

  Future<String?> _saveImageWeb(List<int> bytes, String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsKey = 'hist_img_$id';
      final b64 = base64Encode(bytes is Uint8List
          ? bytes
          : Uint8List.fromList(bytes));
      await prefs.setString(prefsKey, b64);
      return '$_webPrefix$prefsKey';
    } catch (_) {
      return null;
    }
  }

  /// Loads image bytes for display given a stored path/key.
  /// Returns null on native (use Image.file() directly with the path).
  /// Returns Uint8List on web for stored base64 images.
  static Future<Uint8List?> loadImageBytes(String? storedPath) async {
    if (storedPath == null) return null;
    if (!storedPath.startsWith(_webPrefix)) return null; // native — use File
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsKey = storedPath.substring(_webPrefix.length);
      final b64 = prefs.getString(prefsKey);
      if (b64 == null || b64.isEmpty) return null;
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  /// True if this path is a web in-memory reference.
  static bool isWebPath(String? path) =>
      path != null && path.startsWith(_webPrefix);

  // ── Delete ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    String? imagePath;
    String? processedImagePath;
    raw.removeWhere((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      if (map['id'] == id) {
        imagePath = map['imagePath'] as String?;
        processedImagePath = map['processedImagePath'] as String?;
        return true;
      }
      return false;
    });
    await prefs.setStringList(_key, raw);
    await _deleteImage(imagePath, prefs);
    await _deleteImage(processedImagePath, prefs);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    for (final e in raw) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      await _deleteImage(map['imagePath'] as String?, prefs);
      await _deleteImage(map['processedImagePath'] as String?, prefs);
    }
    await prefs.remove(_key);
  }

  Future<void> _deleteImage(String? path, SharedPreferences prefs) async {
    if (path == null) return;
    if (path.startsWith(_webPrefix)) {
      final prefsKey = path.substring(_webPrefix.length);
      await prefs.remove(prefsKey);
    } else {
      await platform.deleteImageFile(path);
    }
  }
}
