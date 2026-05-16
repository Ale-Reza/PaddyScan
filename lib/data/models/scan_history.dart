class ScanHistory {
  final String id;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;
  final String mode; // 'classify' | 'detect' | 'diagnose'
  final String? severity;
  final int? affectedAreas;
  final double? affectedPercentage;
  final String? aiResponse;
  final String? imagePath;           // original image
  final String? processedImagePath;  // AI-annotated image (detect mode)
  final List<Map<String, dynamic>>? topPredictions;

  const ScanHistory({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
    required this.mode,
    this.severity,
    this.affectedAreas,
    this.affectedPercentage,
    this.aiResponse,
    this.imagePath,
    this.processedImagePath,
    this.topPredictions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
        'mode': mode,
        'severity': severity,
        'affectedAreas': affectedAreas,
        'affectedPercentage': affectedPercentage,
        'aiResponse': aiResponse,
        'imagePath': imagePath,
        'processedImagePath': processedImagePath,
        'topPredictions': topPredictions,
      };

  factory ScanHistory.fromJson(Map<String, dynamic> json) => ScanHistory(
        id: json['id'] as String,
        diseaseName: json['diseaseName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        mode: json['mode'] as String,
        severity: json['severity'] as String?,
        affectedAreas: json['affectedAreas'] as int?,
        affectedPercentage: (json['affectedPercentage'] as num?)?.toDouble(),
        aiResponse: json['aiResponse'] as String?,
        imagePath: json['imagePath'] as String?,
        processedImagePath: json['processedImagePath'] as String?,
        topPredictions: (json['topPredictions'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}
