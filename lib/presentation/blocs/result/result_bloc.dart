import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:paddy_scan/core/constants/enums.dart';
import 'package:paddy_scan/data/models/image_data.dart';
import 'package:paddy_scan/data/models/prediction_result.dart';
import 'package:paddy_scan/data/repositories/prediction_repository.dart';

// --- Events ---
abstract class ResultEvent extends Equatable {
  const ResultEvent();
  @override
  List<Object?> get props => [];
}

class StartAnalysisEvent extends ResultEvent {
  final ImageData imageData;
  final AnalysisMode mode;

  const StartAnalysisEvent({required this.imageData, required this.mode});

  @override
  List<Object?> get props => [imageData, mode];
}

class ClearResultEvent extends ResultEvent {}

// --- State ---
class ResultState extends Equatable {
  final PredictionStatus status;
  final PredictionResult? result;
  final String? errorMessage;

  const ResultState({
    this.status = PredictionStatus.initial,
    this.result,
    this.errorMessage,
  });

  ResultState copyWith({
    PredictionStatus? status,
    PredictionResult? result,
    String? errorMessage,
  }) {
    return ResultState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}

// --- Bloc ---
class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final PredictionRepository _predictionRepository;

  ResultBloc({required PredictionRepository predictionRepository})
      : _predictionRepository = predictionRepository,
        super(const ResultState()) {
    on<StartAnalysisEvent>(_onStartAnalysis);
    on<ClearResultEvent>(_onClearResult);
  }

  Future<void> _onStartAnalysis(
    StartAnalysisEvent event,
    Emitter<ResultState> emit,
  ) async {
    emit(state.copyWith(status: PredictionStatus.loading));

    try {
      // 1. Call the Repository (which calls HttpService)
      final prediction = await _predictionRepository.analyze(
        imageData: event.imageData,
        mode: event.mode,
      );

      // 2. Emit success state
      emit(state.copyWith(
        status: PredictionStatus.success,
        result: prediction,
      ));

      // 3. Optional: Trigger a background save to Isar local history here
      // _historyRepository.save(prediction, event.imageData);
    } catch (e) {
      emit(state.copyWith(
        status: PredictionStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onClearResult(ClearResultEvent event, Emitter<ResultState> emit) {
    emit(const ResultState());
  }
}
