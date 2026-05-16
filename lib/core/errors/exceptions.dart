// lib/core/errors/exceptions.dart

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;

  AppException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return '$runtimeType: $message (Original: $originalError)';
    }
    return '$runtimeType: $message';
  }
}

/// Server-related exceptions (HTTP errors, API errors)
class ServerException extends AppException {
  final int? statusCode;

  ServerException(super.message, [this.statusCode, super.originalError]);

  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException: $message (Status: $statusCode)${originalError != null ? ' - Original: $originalError' : ''}';
    }
    return super.toString();
  }
}

/// Network-related exceptions (no internet, timeout, etc.)
class NetworkException extends AppException {
  final bool isTimeout;

  NetworkException(String message,
      {this.isTimeout = false, dynamic originalError})
      : super(message, originalError);

  factory NetworkException.noInternet() = NetworkTimeoutException;
  factory NetworkException.timeout([dynamic originalError]) =
      NetworkTimeoutException;

  @override
  String toString() {
    if (isTimeout) {
      return 'NetworkTimeoutException: $message';
    }
    return 'NetworkException: $message';
  }
}

/// Specific timeout exception
class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException([dynamic originalError])
      : super('Connection timeout',
            isTimeout: true, originalError: originalError);
}

/// Cache/storage related exceptions
class CacheException extends AppException {
  final String? key;

  CacheException(super.message, [this.key, super.originalError]);

  @override
  String toString() {
    if (key != null) {
      return 'CacheException: $message (Key: $key)';
    }
    return super.toString();
  }
}

/// Permission related exceptions
class PermissionException extends AppException {
  final String? permission;

  PermissionException(super.message, [this.permission, super.originalError]);

  bool get isCameraPermission => permission == 'camera';
  bool get isGalleryPermission => permission == 'gallery';

  @override
  String toString() {
    if (permission != null) {
      return 'PermissionException: $message (Permission: $permission)';
    }
    return super.toString();
  }
}

/// Image picking related exceptions
class ImagePickException extends AppException {
  final bool wasCanceled;

  ImagePickException(String message,
      {this.wasCanceled = false, dynamic originalError})
      : super(message, originalError);

  factory ImagePickException.canceled() = ImagePickCanceledException;

  @override
  String toString() {
    if (wasCanceled) {
      return 'ImagePickException: User canceled image selection';
    }
    return super.toString();
  }
}

/// Specific exception for user cancellation
class ImagePickCanceledException extends ImagePickException {
  ImagePickCanceledException() : super('User canceled', wasCanceled: true);
}

/// Analysis related exceptions
class AnalysisException extends AppException {
  final String? stage;

  AnalysisException(super.message, [this.stage, super.originalError]);

  factory AnalysisException.preprocessing(String message, [dynamic error]) =
      AnalysisPreprocessingException;
  factory AnalysisException.classification(String message, [dynamic error]) =
      AnalysisClassificationException;
  factory AnalysisException.detection(String message, [dynamic error]) =
      AnalysisDetectionException;

  @override
  String toString() {
    if (stage != null) {
      return 'AnalysisException ($stage): $message';
    }
    return super.toString();
  }
}

/// Specific preprocessing exception
class AnalysisPreprocessingException extends AnalysisException {
  AnalysisPreprocessingException(String message, [dynamic originalError])
      : super(message, 'preprocessing', originalError);
}

/// Specific classification exception
class AnalysisClassificationException extends AnalysisException {
  AnalysisClassificationException(String message, [dynamic originalError])
      : super(message, 'classification', originalError);
}

/// Specific detection exception
class AnalysisDetectionException extends AnalysisException {
  AnalysisDetectionException(String message, [dynamic originalError])
      : super(message, 'detection', originalError);
}

/// Data Format exception (JSON parsing, etc.)
class DataFormatException extends AppException {
  DataFormatException(super.message, [super.originalError]);
}

/// Authentication exception
class AuthException extends AppException {
  AuthException(super.message, [super.originalError]);
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException(super.message, [this.errors, super.originalError]);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message (Errors: $errors)';
    }
    return super.toString();
  }
}
