// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PaddyScan';

  @override
  String get tagline => 'Detect rice diseases instantly with AI';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get selectImage => 'Select Image';

  @override
  String get analysisSettings => 'Analysis Settings';

  @override
  String get startAnalysis => 'START ANALYSIS';

  @override
  String get classifyMode => 'Classification';

  @override
  String get classifyDesc => 'Identify disease type';

  @override
  String get detectMode => 'Detection';

  @override
  String get detectDesc => 'Locate affected areas';

  @override
  String get diagnoseMode => 'Full Diagnosis';

  @override
  String get diagnoseDesc => 'Full diagnosis report';

  @override
  String get aiExpertDiagnosis => 'AI Expert Diagnosis';

  @override
  String get alternativeMatches => 'Alternative Matches';

  @override
  String get scanAnother => 'SCAN ANOTHER SAMPLE';

  @override
  String get fieldSurvey => 'FIELD SURVEY';

  @override
  String get diagnosticReport => 'DIAGNOSTIC REPORT';

  @override
  String totalSpots(int count) {
    return 'Total Spots: $count';
  }

  @override
  String get spots => 'Spots';

  @override
  String get severity => 'Severity';

  @override
  String get area => 'Area';

  @override
  String get processedNotFound => 'Processed image not found';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get serverConnection => 'Server Connection';

  @override
  String get serverIpAddress => 'Server IP Address';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connected => 'Connected';

  @override
  String get failed => 'Failed';

  @override
  String get language => 'Language';

  @override
  String get urduInterface => 'Urdu Interface';

  @override
  String get urduSubtitle => 'Switch app language to Urdu';

  @override
  String get aiDiagnosis => 'AI Diagnosis';

  @override
  String get enableAI => 'Enable AI Elaboration';

  @override
  String get enableAISubtitle =>
      'Get detailed disease analysis after each scan';

  @override
  String get aiModel => 'AI Model';

  @override
  String get aiModelSubtitle =>
      'Choose which free AI model generates disease reports';

  @override
  String get scanning => 'Scanning';

  @override
  String get highQuality => 'High Quality Upload';

  @override
  String get highQualitySubtitle =>
      'Better accuracy, slower on weak connections';

  @override
  String get showBoxes => 'Show Bounding Boxes';

  @override
  String get showBoxesSubtitle => 'Highlight detected disease regions';

  @override
  String get autoCamera => 'Auto-Open Camera';

  @override
  String get autoCameraSubtitle => 'Launch camera directly on app open';

  @override
  String get notifications => 'Notifications';

  @override
  String get scanReminders => 'Scan Reminders';

  @override
  String get scanRemindersSubtitle => 'Get reminded to scan your crops weekly';

  @override
  String get storage => 'Storage';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Remove temporary scan files';

  @override
  String get clearCacheTitle => 'Clear Cache?';

  @override
  String get clearCacheConfirm =>
      'This will remove all cached scan results and temporary files.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get saving => 'Saving...';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get model => 'Model';

  @override
  String get detectableDiseases => 'Detectable Diseases';

  @override
  String get diseaseGlossary => 'Disease Glossary';

  @override
  String get diseaseGlossarySubtitle => 'View all detectable rice diseases';

  @override
  String get detectableDiseasesList => 'Detectable Diseases';

  @override
  String get aiOffline =>
      'AI service is currently busy. Please try again later.';

  @override
  String get analyzing => 'AI is Analyzing Paddy Sample...';

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String get originalView => 'ORIGINAL VIEW';

  @override
  String get aiPreprocessed => 'AI PREPROCESSED';

  @override
  String get navScan => 'Scan';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get cameraAccessRequired => 'Camera Access Required';

  @override
  String get galleryAccessRequired => 'Gallery Access Required';

  @override
  String get permissionRequired =>
      'PaddyScan needs permission to analyze your rice crops. You can enable this in your device settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get clearHistoryTitle => 'Clear History';

  @override
  String get clearHistoryConfirm =>
      'Delete all scan history? This cannot be undone.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noScansYet => 'No scans yet';

  @override
  String get scanResultsPlaceholder => 'Your scan results will appear here';

  @override
  String get confidenceLabel => 'confidence';

  @override
  String get otherPossibilities => 'Other possibilities';

  @override
  String get aiDisabledMessage =>
      'AI diagnosis is disabled. Enable it in Settings.';

  @override
  String get aiNotAvailableDetection =>
      'AI elaboration is not available for Detection mode.';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get switchToLightTheme => 'Switch to light theme';

  @override
  String get switchToDarkTheme => 'Switch to dark theme';

  @override
  String get testing => 'Testing...';

  @override
  String get couldNotLoadImage => 'Could not load image';

  @override
  String get couldNotDecodeImage => 'Could not decode image';

  @override
  String diseaseAreaDetected(int count) {
    return '$count disease area detected';
  }

  @override
  String diseaseAreasDetected(int count) {
    return '$count disease areas detected';
  }

  @override
  String get aiProcessed => 'AI Processed';

  @override
  String get original => 'Original';

  @override
  String confidencePercent(String value) {
    return '$value% confidence';
  }

  @override
  String get boxesOn => 'Boxes ON';

  @override
  String get boxesOff => 'Boxes OFF';

  @override
  String get splashTagline => 'INTELLIGENT CROP DIAGNOSTICS';

  @override
  String get initializingEngine => 'INITIALIZING NEURAL ENGINE...';

  @override
  String get loadingModels => 'LOADING DISEASE MODELS...';

  @override
  String get calibratingSensors => 'CALIBRATING SENSORS...';

  @override
  String get ready => 'READY';

  @override
  String get imageReady => 'Image Ready';

  @override
  String get analyzeImage => 'Analyze Image';

  @override
  String get newScan => 'New Scan';

  @override
  String get analysisFailed => 'Analysis Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get checkServer => 'Check Server';

  @override
  String get imageDataMissing => 'Image data missing';

  @override
  String get pathAccessRestricted => 'Path access restricted';

  @override
  String get result => 'Result';

  @override
  String timeMinutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String timeHoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String timeDaysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String get timeYesterday => 'Yesterday';
}
