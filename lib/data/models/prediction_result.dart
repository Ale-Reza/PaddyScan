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

    // ✅ Top-level keys from Flask wrapper
    final String modeKey = json['mode']?.toString() ?? '';

    // ✅ All actual data lives inside 'results'
    final results = json['results'] as Map<String, dynamic>? ?? {};

    // ✅ preview_url and processed_image are inside results (added by Flask route)
    final String? previewUrl = results['preview_url'] as String?;
    final String? processedImageUrl = results['processed_image'] as String?;

    String finalLabel = "Healthy / Unknown";
    double finalConf = 0.0;
    int? areas;
    double? percentage;
    String? sev;
    List<BoundingBox> boxes = [];
    List<TopPrediction>? tops;
    Map<String, dynamic>? dims;

    // ── 1. FULL DIAGNOSIS ─────────────────────────────────────────
    if (modeKey == 'diagnosis') {
      // Primary label and confidence
      final primary = results['primary_disease'] as Map<String, dynamic>?;
      if (primary != null) {
        finalLabel = primary['name'] ?? "Multiple Issues";
        finalConf = (primary['confidence'] as num?)?.toDouble() ?? 0.0;
      }

      // ✅ Now uses 'bounding_boxes' (aligned with detect_only)
      final List? rawBoxes = results['bounding_boxes'] as List?;
      if (rawBoxes != null) {
        boxes = rawBoxes
            .map((e) => BoundingBox.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // ✅ Now uses 'affected_areas' (aligned with detect_only)
      areas = results['affected_areas'] as int?;

      // Statistics
      final stats = results['statistics'] as Map<String, dynamic>? ?? {};
      percentage = (stats['affected_percentage'] as num?)?.toDouble();
      sev = stats['severity'] as String?;
      dims = stats['image_dimensions'] as Map<String, dynamic>?;

      // Top predictions from diseases_detected
      final List? detected = results['diseases_detected'] as List?;
      tops = detected
          ?.map((e) => TopPrediction(
                name: e['disease'] ?? '',
                confidence:
                    (e['average_confidence'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();
    }

    // ── 2. DETECTION MODE ─────────────────────────────────────────
    else if (modeKey == 'detection' || results.containsKey('bounding_boxes')) {
      finalLabel = "Detected Affected Areas";

      // ✅ Consistent key 'bounding_boxes'
      final List? boxesJson = results['bounding_boxes'] as List?;
      if (boxesJson != null && boxesJson.isNotEmpty) {
        boxes = boxesJson
            .map((e) => BoundingBox.fromJson(e as Map<String, dynamic>))
            .toList();
        finalConf = boxes[0].confidence;
      }

      // ✅ Consistent key 'affected_areas'
      areas = results['affected_areas'] as int?;

      // Statistics
      final stats = results['statistics'] as Map<String, dynamic>? ?? {};
      percentage = (stats['affected_percentage'] as num?)?.toDouble();
      sev = stats['severity'] as String?;
      dims = stats['image_dimensions'] as Map<String, dynamic>?;
    }

    // ── 3. CLASSIFICATION MODE ────────────────────────────────────
    else if (results.containsKey('primary_diagnosis')) {
      final diag = results['primary_diagnosis'] as Map<String, dynamic>;
      finalLabel = diag['disease'] ?? "Unknown";
      finalConf = (diag['confidence'] as num?)?.toDouble() ?? 0.0;
      final List? top3 = results['top_3_predictions'] as List?;
      tops = top3?.map((e) => TopPrediction.fromJson(e)).toList();
    }

    // ── 4. FALLBACK ───────────────────────────────────────────────
    else {
      finalLabel = results['label'] ?? results['disease'] ?? "Processed";
      finalConf = (results['confidence'] as num?)?.toDouble() ?? 0.0;
    }

    return PredictionResult(
      label: finalLabel,
      confidence: finalConf,
      selectedMode: mode,
      modeName: modeKey,
      previewUrl: previewUrl,           // ✅ from results, not json
      processedImageUrl: processedImageUrl, // ✅ from results, not json
      affectedAreas: areas,
      affectedPercentage: percentage,
      severity: sev,
      boundingBoxes: boxes.isEmpty ? null : boxes,
      description: results['description'] ?? results['treatment'],
      topPredictions: tops,
      originalWidth: (dims?['width'] as num?)?.toDouble() ?? 1.0,
      originalHeight: (dims?['height'] as num?)?.toDouble() ?? 1.0,
      sourceWidth: (dims?['width'] as num?)?.toDouble() ?? 1.0,
      sourceHeight: (dims?['height'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

// ── BoundingBox ───────────────────────────────────────────────────
class BoundingBox {
  final double x1, y1, x2, y2;
  final String className;
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
    final classification = json['classification'] as Map<String, dynamic>?;
    return BoundingBox(
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      // ✅ detection boxes have no classification — fallback to class_name
      className: classification?['disease'] ??
          json['class_name'] ??
          json['label'] ??
          "Disease",
      // ✅ detection confidence at top level, diagnosis inside classification
      confidence: (classification?['confidence'] ?? json['confidence'] as num?)
              ?.toDouble() ??
          0.0,
    );
  }
}

// ── TopPrediction ─────────────────────────────────────────────────
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
