// lib/data/repositories/prediction_repository.dart
import '../models/image_data.dart';
import '../models/prediction_result.dart';
import '../services/ai_service.dart';
import '../../core/constants/enums.dart';

class PredictionRepository {
  final AIService _aiService = AIService();

  // Analyze image
  Future<PredictionResult> analyze({
    required ImageData imageData,
    required AnalysisMode mode,
  }) async {
    try {
      return await _aiService.analyzeImage(imageData, mode: mode);
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  // Check server connection
  Future<bool> checkServerConnection() async {
    try {
      return await _aiService.checkServerHealth();
    } catch (e) {
      return false;
    }
  }

  // Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      return await _aiService.getModelInfo();
    } catch (e) {
      throw Exception('Failed to get model info: $e');
    }
  }

  // Get preview image URL
  Future<String> getPreviewUrl(String previewPath) async {
    return await _aiService.getPreviewUrl(previewPath);
  }

  void dispose() {
    _aiService.dispose();
  }
}
