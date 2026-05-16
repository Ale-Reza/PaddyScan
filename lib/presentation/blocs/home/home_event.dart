import 'package:image_picker/image_picker.dart';
import 'package:paddy_scan/core/constants/enums.dart';

abstract class HomeEvent {
  const HomeEvent();
}

/// Triggered when the user selects Camera or Gallery
class PickImageEvent extends HomeEvent {
  final ImageSource source;
  const PickImageEvent(this.source);
}

/// Triggered when the user changes the Analysis Mode (Classify, Detect, etc.)
class ChangeModeEvent extends HomeEvent {
  final AnalysisMode mode;
  const ChangeModeEvent(this.mode);
}

/// FIXED: Renamed from UploadImageEvent to match your UI's call: AnalyzeImageEvent()
class AnalyzeImageEvent extends HomeEvent {
  const AnalyzeImageEvent();
}

/// NEW: Required for the "New Scan" or "Try Again" buttons in your UI
class ResetStateEvent extends HomeEvent {
  const ResetStateEvent();
}

/// Triggered to check if the Flask server is online
class CheckServerConnection extends HomeEvent {
  const CheckServerConnection();
}

class ClearHomeData extends HomeEvent {
  const ClearHomeData();
}

class ResetResultsOnly extends HomeEvent {
  const ResetResultsOnly();
}

class MarkAsNavigatedEvent extends HomeEvent {
  const MarkAsNavigatedEvent();
}
