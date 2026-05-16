import 'package:flutter/foundation.dart'; // Added for compute
import 'package:image/image.dart' as img;

class ImageUtils {
  // Use a class to namespace these utilities
  ImageUtils._();

  /// Compresses image on a separate thread to keep UI smooth
  static Future<Uint8List> compressImageAsync(Uint8List bytes) async {
    return compute(_compressLogic, bytes);
  }

  static Uint8List _compressLogic(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Pro Tip: If image is already smaller than 1024, don't upscale it!
    if (image.width <= 1024 && image.height <= 1024) {
      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    }

    // Resize maintaining aspect ratio by setting only one dimension
    img.Image resized;
    if (image.width > image.height) {
      resized = img.copyResize(image, width: 1024);
    } else {
      resized = img.copyResize(image, height: 1024);
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  /// Check if image is valid without decoding the WHOLE thing
  /// (Faster than decoding for large files)
  static bool isValidImage(Uint8List bytes) {
    if (bytes.length < 10) return false;
    // Simple magic number check for JPG/PNG
    return (bytes[0] == 0xFF && bytes[1] == 0xD8) || // JPEG
        (bytes[0] == 0x89 && bytes[1] == 0x50); // PNG
  }

  /// Crop to square specifically for AI input
  /// Many models (like MobileNet/YOLO) perform better on square crops
  static Uint8List? cropForAI(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    int size = image.width < image.height ? image.width : image.height;
    final cropped = img.copyCrop(image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size);

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
  }
}
