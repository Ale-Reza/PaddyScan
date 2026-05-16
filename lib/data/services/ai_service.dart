import 'dart:io';
import '../models/image_data.dart';
import '../models/prediction_result.dart';
import 'http_service.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/enums.dart'; // Import shared enum

class AIService {
  final HttpService _httpService = HttpService();

  // Analyze image based on mode
  Future<PredictionResult> analyzeImage(
    ImageData imageData, {
    required AnalysisMode mode,
  }) async {
    try {
      if (imageData.isWeb && imageData.base64 != null) {
        return _analyzeWebImage(imageData.base64!, mode);
      } else if (imageData.isMobile && imageData.path != null) {
        return _analyzeMobileImage(File(imageData.path!), mode);
      } else {
        throw AnalysisException('Invalid image data');
      }
    } on ServerException catch (e) {
      throw AnalysisException('Server error: ${e.message}');
    } on NetworkException catch (e) {
      throw AnalysisException('Network error: ${e.message}');
    } catch (e) {
      throw AnalysisException('Unexpected error: $e');
    }
  }

  // Mobile analysis
  Future<PredictionResult> _analyzeMobileImage(
    File imageFile,
    AnalysisMode mode,
  ) async {
    switch (mode) {
      case AnalysisMode.classify:
        return await _httpService.classifyImage(imageFile);
      case AnalysisMode.detect:
        return await _httpService.detectImage(imageFile);
      case AnalysisMode.diagnose:
        return await _httpService.diagnoseImage(imageFile);
    }
  }

  // Web analysis
  Future<PredictionResult> _analyzeWebImage(
    String base64Image,
    AnalysisMode mode,
  ) async {
    return await _httpService.classifyImageWeb(base64Image);
  }

  // Check server health
  Future<bool> checkServerHealth() => _httpService.checkHealth();

  // Get model info
  Future<Map<String, dynamic>> getModelInfo() => _httpService.getModelInfo();

  // Get preview URL
  Future<String> getPreviewUrl(String previewPath) =>
      _httpService.getPreviewUrl(previewPath);

  void dispose() {
    _httpService.dispose();
  }
}
