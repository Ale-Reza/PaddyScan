import '../../core/constants/enums.dart';

class PredictionResult {
  final String label;
  final double confidence;
  final AnalysisMode selectedMode;
  final String? modeName;
  final String? previewUrl;
  final String? processedImageUrl;

  // Detection & Statistics Fields
  final int? affectedAreas;
  final double? affectedPercentage;
  final double? sourceWidth;
  final double? sourceHeight;
  final String? severity;
  final List<BoundingBox>? boundingBoxes;

  // Diagnosis & AI Fields
  final String? description;
  final List<TopPrediction>? topPredictions;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.selectedMode,
    this.modeName,
    this.previewUrl,
    this.affectedAreas,
    this.affectedPercentage,
    this.severity,
    this.boundingBoxes,
    this.description,
    this.topPredictions,
    this.processedImageUrl,
    required double originalWidth,
    required double originalHeight,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  factory PredictionResult.fromJson(
      Map<String, dynamic> json, AnalysisMode mode) {
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final String modeKey = json['mode']?.toString() ?? '';
    final stats = json['statistics'] as Map<String, dynamic>?;
    var dims = stats?['image_dimensions'] as Map<String, dynamic>?;

    String finalLabel = "Healthy / Unknown";
    double finalConf = 0.0;
    int? areas;
    double? percentage;
    String? sev;
    List<BoundingBox> boxes = [];
    List<TopPrediction>? tops;

    // --- 1. HANDLE FULL DIAGNOSIS  ---
    if (modeKey == 'diagnosis') {
      // 1. Handle Primary Label and Confidence (This was correct)
      final primary = results['primary_disease'] as Map<String, dynamic>?;
      if (primary != null) {
        finalLabel = primary['name'] ?? "Multiple Issues";
        finalConf = (primary['confidence'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Map Bounding Boxes - FIXED: Use 'classified_areas' instead of 'statistics'
      final List? rawBoxes = results['classified_areas'] as List?;
      if (rawBoxes != null) {
        boxes = rawBoxes.map((e) => BoundingBox.fromJson(e)).toList();
      }

      // 3. Handle Affected Areas - FIXED: Matches Python 'total_affected_areas'
      areas = results['total_affected_areas'] as int?;

      // 4. Handle Statistics - FIXED: Use the correct nested paths
      final stats = results['statistics'] as Map<String, dynamic>? ?? {};

      // Extracting from the statistics Map
      percentage = (stats['affected_percentage'] as num?)?.toDouble();
      sev = stats['severity'] as String?;

      // Extracting dimensions for the Painter
      dims = stats['image_dimensions'] as Map<String, dynamic>?;

      // 5. Map Top Predictions (This was correct)
      final List? detected = results['diseases_detected'] as List?;
      tops = detected
          ?.map((e) => TopPrediction(
                name: e['disease'] ?? '',
                confidence:
                    (e['average_confidence'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();
    }
    // --- 2. HANDLE DETECTION MODE ---
    else if (results.containsKey('bounding_boxes') || modeKey == 'detection') {
      final List? boxesJson = results['bounding_boxes'] as List?;
      finalLabel = "Detected Affected Areas";

      if (boxesJson != null && boxesJson.isNotEmpty) {
        boxes = boxesJson.map((e) => BoundingBox.fromJson(e)).toList();
        finalConf = boxes[0].confidence;
      }

      areas = results['affected_areas'];

      // FIX: Look for statistics inside the 'results' map for detection mode
      final stats = results['statistics'] as Map<String, dynamic>? ?? {};

      // FIX: Update dims here so the return statement at the bottom sees it!

      dims = stats['image_dimensions'] as Map<String, dynamic>?;
      percentage = (stats['affected_percentage'] as num?)?.toDouble();
      sev = stats['severity'];
    }

    // --- 3. HANDLE CLASSIFICATION MODE ---
    else if (results.containsKey('primary_diagnosis')) {
      final diag = results['primary_diagnosis'] as Map<String, dynamic>;
      finalLabel = diag['disease'] ?? "Unknown";
      finalConf = (diag['confidence'] as num?)?.toDouble() ?? 0.0;
      final List? top3 = results['top_3_predictions'] as List?;
      tops = top3?.map((e) => TopPrediction.fromJson(e)).toList();
    }

    // --- 4. FALLBACK ---
    else {
      finalLabel = results['label'] ?? results['disease'] ?? "Processed";
      finalConf = (results['confidence'] as num?)?.toDouble() ?? 0.0;
    }

    return PredictionResult(
      label: finalLabel,
      confidence: finalConf,
      selectedMode: mode,
      modeName: modeKey,
      previewUrl: json['preview_url'],
      affectedAreas: areas,
      affectedPercentage: percentage,
      severity: sev,
      boundingBoxes: boxes,
      description: json['description'] ?? json['treatment'],
      topPredictions: tops,
      processedImageUrl: json['processed_image'],
      originalWidth: (dims?['width'] as num?)?.toDouble() ?? 1.0,
      originalHeight: (dims?['height'] as num?)?.toDouble() ?? 1.0,
      sourceWidth: (dims?['width'] as num?)?.toDouble() ?? 1.0,
      sourceHeight: (dims?['height'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Model for Object Detection Bounding Boxes
class BoundingBox {
  final double x1, y1, x2, y2;
  final String className; // Your property name
  final double confidence;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.className,
    required this.confidence,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    // 1. Extract the nested classification map from Flask
    final classification = json['classification'] as Map<String, dynamic>?;

    return BoundingBox(
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      className:
          json['classification']?['disease'] ?? json['class_name'] ?? "Unknown",
      confidence: (classification?['confidence'] ?? json['confidence'] as num?)
              ?.toDouble() ??
          0.0,
    );
  }
}

/// Model for Top 3 Classification Results
class TopPrediction {
  final String name;
  final double confidence;

  TopPrediction({required this.name, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      name: json['disease'] ?? json['label'] ?? json['class'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
