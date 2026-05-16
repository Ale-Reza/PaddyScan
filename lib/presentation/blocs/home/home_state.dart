import 'package:equatable/equatable.dart';
import '../../../data/models/image_data.dart';
import '../../../data/models/prediction_result.dart';
import '../../../core/constants/enums.dart';

class HomeState extends Equatable {
  final PredictionStatus status;
  final bool isConnected;
  final AnalysisMode selectedMode;
  final ImageData? imageData;
  final PredictionResult? result;
  final String? errorMessage;
  final Map<String, dynamic>? modelInfo;
  final bool hasNavigated;

  const HomeState({
    this.status = PredictionStatus.initial,
    this.isConnected = false,
    this.selectedMode = AnalysisMode.classify, // Synced with your enum
    this.imageData,
    this.result,
    this.errorMessage,
    this.modelInfo,
    this.hasNavigated = false,
  });

  // --- PRO TIP: Helper getters for the UI ---
  bool get isLoading => status == PredictionStatus.loading;
  bool get isReady => imageData != null && status == PredictionStatus.initial;
  bool get hasResult => result != null;

  HomeState copyWith({
    PredictionStatus? status,
    bool? isConnected,
    AnalysisMode? selectedMode,
    ImageData? imageData,
    // We allow these to be wrapped in a function or checked specifically
    // to allow resetting them to null
    PredictionResult? Function()? result,
    String? Function()? errorMessage,
    Map<String, dynamic>? modelInfo,
    bool? hasNavigated,
  }) {
    return HomeState(
      status: status ?? this.status,
      isConnected: isConnected ?? this.isConnected,
      selectedMode: selectedMode ?? this.selectedMode,
      imageData: imageData ?? this.imageData,
      // If a function is passed, call it; otherwise, keep current value
      result: result != null ? result() : this.result,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      modelInfo: modelInfo ?? this.modelInfo,
      hasNavigated: hasNavigated ?? this.hasNavigated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isConnected,
        selectedMode,
        imageData,
        result,
        errorMessage,
        modelInfo,
        hasNavigated,
      ];
}
