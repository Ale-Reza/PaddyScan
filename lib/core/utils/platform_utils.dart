import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' as picker;
import 'package:paddy_scan/core/constants/enums.dart' as app;

class PlatformUtils {
  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on Fuchsia
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Check if running on desktop
  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isFuchsia);

  /// Get platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    if (isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  /// Check if camera is available on this platform
  static bool get isCameraAvailable {
    return isMobile; // Camera only reliably available on mobile
  }

  /// Get max image dimensions based on platform
  static int get maxImageDimension {
    if (isWeb) return 800;
    if (isMobile) return 1024;
    return 1200; // Desktop
  }

  /// Get image quality based on platform
  static int get imageQuality {
    if (isWeb) return 80;
    if (isMobile) return 85;
    return 90; // Desktop
  }

  /// Get appropriate image source based on platform (using picker.ImageSource)
  static picker.ImageSource get defaultPickerSource {
    if (isMobile) return picker.ImageSource.camera;
    return picker.ImageSource.gallery;
  }

  /// Get appropriate app image source based on platform (using app.ImageCaptureSource)
  static app.ImageCaptureSource get defaultAppSource {
    if (isMobile) return app.ImageCaptureSource.camera;
    return app.ImageCaptureSource.gallery;
  }

  /// Check if running in debug mode
  static bool get isDebugMode {
    bool inDebug = false;
    assert(inDebug = true);
    return inDebug;
  }

  /// Get platform info as a map
  static Map<String, bool> get platformInfo {
    return {
      'isWeb': isWeb,
      'isIOS': isIOS,
      'isAndroid': isAndroid,
      'isMacOS': isMacOS,
      'isWindows': isWindows,
      'isLinux': isLinux,
      'isFuchsia': isFuchsia,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isCameraAvailable': isCameraAvailable,
    };
  }

  /// Convert picker.ImageSource to app.ImageCaptureSource
  static app.ImageCaptureSource pickerSourceToAppSource(
          picker.ImageSource source) =>
      switch (source) {
        picker.ImageSource.camera => app.ImageCaptureSource.camera,
        picker.ImageSource.gallery => app.ImageCaptureSource.gallery,
      };

  /// Convert app.ImageCaptureSource to picker.ImageSource
  static picker.ImageSource appSourceToPickerSource(
      app.ImageCaptureSource source) {
    switch (source) {
      case app.ImageCaptureSource.camera:
        return picker.ImageSource.camera;
      case app.ImageCaptureSource.gallery:
        return picker.ImageSource.gallery;
    }
    // No need for fallback return - switch is exhaustive
  }
}
