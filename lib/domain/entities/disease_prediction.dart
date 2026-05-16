class DiseasePredictionEntity {
  final String name;
  final double confidence;
  final int classId;

  const DiseasePredictionEntity({
    required this.name,
    required this.confidence,
    required this.classId,
  });
}

class BoundingBoxEntity {
  final int x1, y1, x2, y2;
  final double confidence;
  final int? classId;
  final String? className;
  final int area;

  const BoundingBoxEntity({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.confidence,
    this.classId,
    this.className,
    required this.area,
  });
}

class PredictionResultEntity {
  final String primaryDisease;
  final double confidence;
  final List<String> topDiseases;
  final int? affectedAreas;
  final String? severity;
  final double? affectedPercentage;
  final String? previewUrl;

  const PredictionResultEntity({
    required this.primaryDisease,
    required this.confidence,
    required this.topDiseases,
    this.affectedAreas,
    this.severity,
    this.affectedPercentage,
    this.previewUrl,
  });
}
