import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/permission_service.dart';

class ImageRepository {
  final ImagePicker _picker = ImagePicker();
  final PermissionService _permissionService;

  ImageRepository(this._permissionService);

  Future<Uint8List?> pickImage(ImageSource source, BuildContext context) async {
    bool permitted = true;

    // Permissions are only required for mobile (Android/iOS)
    if (!kIsWeb) {
      final permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;
      permitted =
          await _permissionService.requestPermission(permission, context);
    }

    if (!permitted) {
      // Instead of a generic Exception, you can return null or
      // handle "Permanently Denied" logic here.
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final highQuality = prefs.getBool('high_quality_image') ?? true;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: highQuality ? 85 : 50,
      maxWidth: 1080,
    );

    if (picked == null) return null;

    // Returns the bytes directly for use in your ResultPage or HistoryPage
    return await picked.readAsBytes();
  }
}
