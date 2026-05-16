import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:paddy_scan/core/constants/enums.dart';

class ImageData extends Equatable {
  final String? path;
  final String? base64;
  final DateTime timestamp;
  final ImageCaptureSource source;
  final int? width;
  final int? height;

  // Static helper for platform detection
  static bool get isWebPlatform => identical(0, 0.0);

  const ImageData({
    this.path,
    this.base64,
    required this.timestamp,
    required this.source,
    this.width,
    this.height,
  });

  // For mobile (File)
  factory ImageData.fromFile(
    File file, {
    required ImageCaptureSource source,
    int? width,
    int? height,
  }) {
    return ImageData(
      path: file.path,
      timestamp: DateTime.now(),
      source: source,
      width: width,
      height: height,
    );
  }

  // For web (Base64)
  factory ImageData.fromBase64(
    String base64, {
    required ImageCaptureSource source,
    int? width,
    int? height,
  }) {
    return ImageData(
      base64: base64,
      timestamp: DateTime.now(),
      source: source,
      width: width,
      height: height,
    );
  }

  // INSTANCE GETTERS
  bool get isWeb => base64 != null;
  bool get isMobile => path != null;

  // Helper getters
  String get fileName {
    if (isMobile && path != null) {
      return path!.split(Platform.pathSeparator).last;
    }
    return 'image_${timestamp.millisecondsSinceEpoch}.jpg';
  }

  String get fileExtension {
    if (isMobile && path != null) {
      return path!.split('.').last;
    }
    return 'jpg';
  }

  int get fileSize {
    // This would need actual file size calculation
    // For now, returns 0
    return 0;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'base64': base64,
      'timestamp': timestamp.toIso8601String(),
      'source': source.toString(),
      'width': width,
      'height': height,
    };
  }

  // Create from JSON
  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      path: json['path'],
      base64: json['base64'],
      timestamp: DateTime.parse(json['timestamp']),
      source: ImageCaptureSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => ImageCaptureSource.gallery,
      ),
      width: json['width'],
      height: json['height'],
    );
  }

  // Create a copy with modified fields
  ImageData copyWith({
    String? path,
    String? base64,
    DateTime? timestamp,
    ImageCaptureSource? source,
    int? width,
    int? height,
  }) {
    return ImageData(
      path: path ?? this.path,
      base64: base64 ?? this.base64,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [path, base64, timestamp, source, width, height];
}
