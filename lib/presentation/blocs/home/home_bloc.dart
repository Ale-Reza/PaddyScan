import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paddy_scan/core/constants/enums.dart';
import 'package:paddy_scan/core/errors/exceptions.dart';
import 'package:paddy_scan/core/utils/image_utils.dart';
import 'package:paddy_scan/data/models/image_data.dart';
import 'package:paddy_scan/data/repositories/homeRepositoryImpl.dart';
import 'package:paddy_scan/data/services/api_service.dart';
import 'package:paddy_scan/presentation/blocs/home/home_event.dart';
import 'package:paddy_scan/presentation/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService apiService;
  final HomeRepository homeRepository; // Added Repository
  final ImagePicker _picker = ImagePicker();

  // Update constructor to require homeRepository
  HomeBloc({
    required this.apiService,
    required this.homeRepository,
  }) : super(const HomeState()) {
    on<PickImageEvent>(_onPickImage);
    on<AnalyzeImageEvent>(_onAnalyzeImage);
    on<ChangeModeEvent>(_onChangeMode);
    on<CheckServerConnection>(_onCheckConnection);
    on<ResetStateEvent>(_onResetState);
    on<MarkAsNavigatedEvent>((event, emit) {
      emit(state.copyWith(hasNavigated: true));
    });
    on<ClearHomeData>((event, emit) {
      emit(const HomeState());
    });
    // Inside HomeBloc constructor
    on<ResetResultsOnly>((event, emit) {
      emit(state.copyWith(
        status: PredictionStatus.initial, // Ready for a new analysis
        result: () => null, // Clears the disease diagnosis
        errorMessage: () => null,
        hasNavigated: false,
        // Clears any previous errors
        // Note: imageData is NOT passed, so it remains in state
      ));
    });
  }
  void _onResetState(ResetStateEvent event, Emitter<HomeState> emit) {
    emit(const HomeState());
  }

  Future<void> _onPickImage(
      PickImageEvent event, Emitter<HomeState> emit) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: event.source,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      emit(state.copyWith(status: PredictionStatus.loading));

      final Uint8List originalBytes = await pickedFile.readAsBytes();
      final Uint8List compressedBytes =
          await ImageUtils.compressImageAsync(originalBytes);
      final base64Image = base64Encode(compressedBytes);

      final modelSource = event.source == ImageSource.camera
          ? ImageCaptureSource.camera
          : ImageCaptureSource.gallery;

      emit(state.copyWith(
        imageData: ImageData(
          path: pickedFile.path,
          base64: base64Image,
          timestamp: DateTime.now(),
          source: modelSource,
        ),
        status: PredictionStatus.initial,
        errorMessage: () => null, // ✅ Correct: Pass as a function
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PredictionStatus.error,
        errorMessage: () =>
            "Failed to process image: ${e.toString()}", // ✅ Correct
      ));
    }
  }

  Future<void> _onAnalyzeImage(
      AnalyzeImageEvent event, Emitter<HomeState> emit) async {
    final imageData = state.imageData;

    if (imageData == null) {
      emit(state.copyWith(
          status: PredictionStatus.error,
          errorMessage: () => "No image selected."));
      return;
    }

    emit(state.copyWith(
        status: PredictionStatus.loading, errorMessage: () => null));

    try {
      // 1. Get result from API
      final result =
          await apiService.uploadImage(imageData.base64!, state.selectedMode);

      // 2. Prepare image bytes for Isar
      // We decode the base64 string back to bytes for storage
      final Uint8List imageBytes = base64Decode(imageData.base64!);

      // 3. Trigger the Isar save via Repository
      // This is a "fire and forget" or await depending on your preference
      await homeRepository.processAndSaveResult(result, imageBytes);

      emit(state.copyWith(
        status: PredictionStatus.success,
        result: () => result,
        hasNavigated: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PredictionStatus.error,
        errorMessage: () => _mapErrorToMessage(e),
      ));
    }
  }

  void _onChangeMode(ChangeModeEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedMode: event.mode));
  }

  Future<void> _onCheckConnection(
      CheckServerConnection event, Emitter<HomeState> emit) async {
    try {
      final isAlive = await apiService.checkHealth();
      emit(state.copyWith(isConnected: isAlive));
    } catch (_) {
      emit(state.copyWith(isConnected: false));
    }
  }

  String _mapErrorToMessage(Object e) {
    if (e is NetworkException) return "Server unreachable. Check Flask.";
    if (e is ServerException) return "Server Error (${e.statusCode})";
    return "Error: ${e.toString()}";
  }
}
