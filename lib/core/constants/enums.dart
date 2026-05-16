// lib/core/constants/enums.dart

import 'package:flutter/material.dart';
import 'package:paddy_scan/core/constants/app_colors.dart';

enum AnalysisMode { classify, detect, diagnose }

enum PredictionStatus { initial, loading, success, error }

enum DetectionSeverity { minimal, mild, moderate, severe }

enum ImageCaptureSource { camera, gallery }

// --- AnalysisMode Extension ---
extension AnalysisModeExtension on AnalysisMode {
  String get displayName {
    switch (this) {
      case AnalysisMode.classify:
        return 'Classification';
      case AnalysisMode.detect:
        return 'Detection';
      case AnalysisMode.diagnose:
        return 'Full Diagnosis';
    }
  }

  // FIXED: Only handle AnalysisMode colors here
  Color get color {
    switch (this) {
      case AnalysisMode.classify:
        return AppColors.classify;
      case AnalysisMode.detect:
        return AppColors.detect;
      case AnalysisMode.diagnose:
        return AppColors.diagnose;
    }
  }

  String get apiEndpoint {
    switch (this) {
      case AnalysisMode.classify:
        return '/api/classify';
      case AnalysisMode.detect:
        return '/api/detect';
      case AnalysisMode.diagnose:
        return '/api/diagnose';
    }
  }

  IconData get icon {
    switch (this) {
      case AnalysisMode.classify:
        return Icons.search;
      case AnalysisMode.detect:
        return Icons.location_on;
      case AnalysisMode.diagnose:
        return Icons.medical_services;
    }
  }

  String get description {
    switch (this) {
      case AnalysisMode.classify:
        return 'Identify disease only';
      case AnalysisMode.detect:
        return 'Find affected areas';
      case AnalysisMode.diagnose:
        return 'Complete analysis';
    }
  }
}

// --- DetectionSeverity Extension ---
extension DetectionSeverityExtension on DetectionSeverity {
  String get displayName {
    switch (this) {
      case DetectionSeverity.minimal:
        return 'Minimal';
      case DetectionSeverity.mild:
        return 'Mild';
      case DetectionSeverity.moderate:
        return 'Moderate';
      case DetectionSeverity.severe:
        return 'Severe';
    }
  }

  // ADDED: Severity-specific colors moved here
  Color get color {
    switch (this) {
      case DetectionSeverity.minimal:
        return AppColors.success;
      case DetectionSeverity.mild:
        return AppColors.warning;
      case DetectionSeverity.moderate:
        return AppColors.secondaryOrange;
      case DetectionSeverity.severe:
        return AppColors.error;
    }
  }

  double get threshold {
    switch (this) {
      case DetectionSeverity.minimal:
        return 5.0;
      case DetectionSeverity.mild:
        return 15.0;
      case DetectionSeverity.moderate:
        return 30.0;
      case DetectionSeverity.severe:
        return 50.0;
    }
  }

  static DetectionSeverity fromPercentage(double percentage) {
    if (percentage >= 50) return DetectionSeverity.severe;
    if (percentage >= 30) return DetectionSeverity.moderate;
    if (percentage >= 15) return DetectionSeverity.mild;
    return DetectionSeverity.minimal;
  }
}

// --- ImageCaptureSource Extension ---
extension ImageCaptureSourceExtension on ImageCaptureSource {
  String get displayName {
    switch (this) {
      case ImageCaptureSource.camera:
        return 'Camera';
      case ImageCaptureSource.gallery:
        return 'Gallery';
    }
  }

  IconData get icon {
    switch (this) {
      case ImageCaptureSource.camera:
        return Icons.camera_alt;
      case ImageCaptureSource.gallery:
        return Icons.photo_library;
    }
  }
}

// --- PredictionStatus Extension ---
extension PredictionStatusExtension on PredictionStatus {
  bool get isLoading => this == PredictionStatus.loading;
  bool get isSuccess => this == PredictionStatus.success;
  bool get isError => this == PredictionStatus.error;
  bool get isInitial => this == PredictionStatus.initial;
}
