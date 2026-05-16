import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:cross_file/cross_file.dart';
import 'package:paddy_scan/core/constants/enums.dart';
import '../../data/models/image_data.dart';
import '../../core/utils/platform_utils.dart';

class PickImageUseCase {
  final picker.ImagePicker _picker = picker.ImagePicker();

  Future<ImageData?> execute({required bool fromCamera}) async {
    try {
      // Check if camera is requested but not available
      if (fromCamera && !PlatformUtils.isCameraAvailable) {
        throw Exception('Camera is not available on this platform');
      }

      // Get the appropriate picker source
      final pickerSource =
          fromCamera ? picker.ImageSource.camera : picker.ImageSource.gallery;

      // Use platform-specific settings
      final maxDimension = PlatformUtils.maxImageDimension;
      final quality = PlatformUtils.imageQuality;

      // Web platform
      if (PlatformUtils.isWeb) {
        final XFile? pickedFile = await _picker.pickImage(
          source: pickerSource,
          maxWidth: maxDimension.toDouble(),
          maxHeight: maxDimension.toDouble(),
          imageQuality: quality,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);

          final appSource = PlatformUtils.pickerSourceToAppSource(pickerSource);

          return ImageData.fromBase64(
            base64Image,
            source: appSource,
          );
        }
      }
      // Mobile/Desktop platform
      else {
        final XFile? pickedFile = await _picker.pickImage(
          source: pickerSource,
          maxWidth: maxDimension.toDouble(),
          maxHeight: maxDimension.toDouble(),
          imageQuality: quality,
        );

        if (pickedFile != null) {
          final appSource = PlatformUtils.pickerSourceToAppSource(pickerSource);

          return ImageData.fromFile(
            File(pickedFile.path),
            source: appSource,
          );
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Optional: Add method to pick multiple images
  Future<List<ImageData>?> pickMultipleImages() async {
    try {
      if (PlatformUtils.isWeb) {
        // Web doesn't support multiple image picking well
        throw Exception('Multiple image picking not supported on web');
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: PlatformUtils.maxImageDimension.toDouble(),
        maxHeight: PlatformUtils.maxImageDimension.toDouble(),
        imageQuality: PlatformUtils.imageQuality,
      );

      if (pickedFiles.isEmpty) return null;

      final List<ImageData> images = [];
      for (final pickedFile in pickedFiles) {
        images.add(
          ImageData.fromFile(
            File(pickedFile.path),
            source: ImageCaptureSource.gallery,
          ),
        );
      }

      return images;
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }
}
