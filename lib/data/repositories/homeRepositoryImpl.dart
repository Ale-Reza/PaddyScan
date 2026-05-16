import 'dart:developer' as dev;
import 'package:paddy_scan/data/models/prediction_result.dart';
import 'package:paddy_scan/data/services/api_service.dart';

abstract class HomeRepository {
  Future<void> processAndSaveResult(
      PredictionResult result, List<int> imageBytes);
}

class HomeRepositoryImpl implements HomeRepository {
  final ApiService apiService;

  HomeRepositoryImpl({required this.apiService});

  @override
  Future<void> processAndSaveResult(
      PredictionResult result, List<int> imageBytes) async {
    // We use the 'label' and 'confidence' getters we just added to PredictionResult
    final disease = result.label;
    final confidenceScore = result.confidence * 100;

    dev.log(
      '--- SCAN SUCCESSFUL ---',
      name: 'PaddyScan.Repo',
      // This will show up in your VS Code / Android Studio 'Developer Console'
      error:
          'Detected: $disease | Confidence: ${confidenceScore.toStringAsFixed(2)}%',
    );

    // Note: Since Isar is removed, 'imageBytes' isn't being used right now.
    // This is fine for a demo focused on AI accuracy.
  }
}
