import '../../data/models/image_data.dart';
import '../../data/models/prediction_result.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../core/constants/enums.dart'; // Import the shared enum

class UploadImageUseCase {
  final PredictionRepository _repository;

  UploadImageUseCase(this._repository);

  Future<PredictionResult> execute({
    required ImageData imageData,
    required AnalysisMode mode, // This now uses the enum from enums.dart
  }) async {
    // Validate image
    if (imageData.isMobile && imageData.path == null) {
      throw Exception('Invalid image path');
    }
    if (imageData.isWeb && imageData.base64 == null) {
      throw Exception('Invalid image data');
    }

    // Perform analysis
    return await _repository.analyze(
      imageData: imageData,
      mode: mode,
    );
  }
}
