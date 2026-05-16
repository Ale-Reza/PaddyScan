import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PaddyScan'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Detect rice diseases instantly with AI'**
  String get tagline;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @analysisSettings.
  ///
  /// In en, this message translates to:
  /// **'Analysis Settings'**
  String get analysisSettings;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'START ANALYSIS'**
  String get startAnalysis;

  /// No description provided for @classifyMode.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classifyMode;

  /// No description provided for @classifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Identify disease type'**
  String get classifyDesc;

  /// No description provided for @detectMode.
  ///
  /// In en, this message translates to:
  /// **'Detection'**
  String get detectMode;

  /// No description provided for @detectDesc.
  ///
  /// In en, this message translates to:
  /// **'Locate affected areas'**
  String get detectDesc;

  /// No description provided for @diagnoseMode.
  ///
  /// In en, this message translates to:
  /// **'Full Diagnosis'**
  String get diagnoseMode;

  /// No description provided for @diagnoseDesc.
  ///
  /// In en, this message translates to:
  /// **'Full diagnosis report'**
  String get diagnoseDesc;

  /// No description provided for @aiExpertDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Expert Diagnosis'**
  String get aiExpertDiagnosis;

  /// No description provided for @alternativeMatches.
  ///
  /// In en, this message translates to:
  /// **'Alternative Matches'**
  String get alternativeMatches;

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'SCAN ANOTHER SAMPLE'**
  String get scanAnother;

  /// No description provided for @fieldSurvey.
  ///
  /// In en, this message translates to:
  /// **'FIELD SURVEY'**
  String get fieldSurvey;

  /// No description provided for @diagnosticReport.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSTIC REPORT'**
  String get diagnosticReport;

  /// No description provided for @totalSpots.
  ///
  /// In en, this message translates to:
  /// **'Total Spots: {count}'**
  String totalSpots(int count);

  /// No description provided for @spots.
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get spots;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @processedNotFound.
  ///
  /// In en, this message translates to:
  /// **'Processed image not found'**
  String get processedNotFound;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @serverConnection.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get serverConnection;

  /// No description provided for @serverIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Server IP Address'**
  String get serverIpAddress;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @urduInterface.
  ///
  /// In en, this message translates to:
  /// **'Urdu Interface'**
  String get urduInterface;

  /// No description provided for @urduSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch app language to Urdu'**
  String get urduSubtitle;

  /// No description provided for @aiDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get aiDiagnosis;

  /// No description provided for @enableAI.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Elaboration'**
  String get enableAI;

  /// No description provided for @enableAISubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get detailed disease analysis after each scan'**
  String get enableAISubtitle;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @aiModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which free AI model generates disease reports'**
  String get aiModelSubtitle;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @highQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality Upload'**
  String get highQuality;

  /// No description provided for @highQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Better accuracy, slower on weak connections'**
  String get highQualitySubtitle;

  /// No description provided for @showBoxes.
  ///
  /// In en, this message translates to:
  /// **'Show Bounding Boxes'**
  String get showBoxes;

  /// No description provided for @showBoxesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight detected disease regions'**
  String get showBoxesSubtitle;

  /// No description provided for @autoCamera.
  ///
  /// In en, this message translates to:
  /// **'Auto-Open Camera'**
  String get autoCamera;

  /// No description provided for @autoCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Launch camera directly on app open'**
  String get autoCameraSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @scanReminders.
  ///
  /// In en, this message translates to:
  /// **'Scan Reminders'**
  String get scanReminders;

  /// No description provided for @scanRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded to scan your crops weekly'**
  String get scanRemindersSubtitle;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove temporary scan files'**
  String get clearCacheSubtitle;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all cached scan results and temporary files.'**
  String get clearCacheConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @detectableDiseases.
  ///
  /// In en, this message translates to:
  /// **'Detectable Diseases'**
  String get detectableDiseases;

  /// No description provided for @diseaseGlossary.
  ///
  /// In en, this message translates to:
  /// **'Disease Glossary'**
  String get diseaseGlossary;

  /// No description provided for @diseaseGlossarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all detectable rice diseases'**
  String get diseaseGlossarySubtitle;

  /// No description provided for @detectableDiseasesList.
  ///
  /// In en, this message translates to:
  /// **'Detectable Diseases'**
  String get detectableDiseasesList;

  /// No description provided for @aiOffline.
  ///
  /// In en, this message translates to:
  /// **'AI service is currently busy. Please try again later.'**
  String get aiOffline;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is Analyzing Paddy Sample...'**
  String get analyzing;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @originalView.
  ///
  /// In en, this message translates to:
  /// **'ORIGINAL VIEW'**
  String get originalView;

  /// No description provided for @aiPreprocessed.
  ///
  /// In en, this message translates to:
  /// **'AI PREPROCESSED'**
  String get aiPreprocessed;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @cameraAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Required'**
  String get cameraAccessRequired;

  /// No description provided for @galleryAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery Access Required'**
  String get galleryAccessRequired;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'PaddyScan needs permission to analyze your rice crops. You can enable this in your device settings.'**
  String get permissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all scan history? This cannot be undone.'**
  String get clearHistoryConfirm;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noScansYet;

  /// No description provided for @scanResultsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your scan results will appear here'**
  String get scanResultsPlaceholder;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidenceLabel;

  /// No description provided for @otherPossibilities.
  ///
  /// In en, this message translates to:
  /// **'Other possibilities'**
  String get otherPossibilities;

  /// No description provided for @aiDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'AI diagnosis is disabled. Enable it in Settings.'**
  String get aiDisabledMessage;

  /// No description provided for @aiNotAvailableDetection.
  ///
  /// In en, this message translates to:
  /// **'AI elaboration is not available for Detection mode.'**
  String get aiNotAvailableDetection;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @switchToLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get switchToLightTheme;

  /// No description provided for @switchToDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToDarkTheme;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @couldNotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get couldNotLoadImage;

  /// No description provided for @couldNotDecodeImage.
  ///
  /// In en, this message translates to:
  /// **'Could not decode image'**
  String get couldNotDecodeImage;

  /// No description provided for @diseaseAreaDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} disease area detected'**
  String diseaseAreaDetected(int count);

  /// No description provided for @diseaseAreasDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} disease areas detected'**
  String diseaseAreasDetected(int count);

  /// No description provided for @aiProcessed.
  ///
  /// In en, this message translates to:
  /// **'AI Processed'**
  String get aiProcessed;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @confidencePercent.
  ///
  /// In en, this message translates to:
  /// **'{value}% confidence'**
  String confidencePercent(String value);

  /// No description provided for @boxesOn.
  ///
  /// In en, this message translates to:
  /// **'Boxes ON'**
  String get boxesOn;

  /// No description provided for @boxesOff.
  ///
  /// In en, this message translates to:
  /// **'Boxes OFF'**
  String get boxesOff;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENT CROP DIAGNOSTICS'**
  String get splashTagline;

  /// No description provided for @initializingEngine.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZING NEURAL ENGINE...'**
  String get initializingEngine;

  /// No description provided for @loadingModels.
  ///
  /// In en, this message translates to:
  /// **'LOADING DISEASE MODELS...'**
  String get loadingModels;

  /// No description provided for @calibratingSensors.
  ///
  /// In en, this message translates to:
  /// **'CALIBRATING SENSORS...'**
  String get calibratingSensors;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @imageReady.
  ///
  /// In en, this message translates to:
  /// **'Image Ready'**
  String get imageReady;

  /// No description provided for @analyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Analyze Image'**
  String get analyzeImage;

  /// No description provided for @newScan.
  ///
  /// In en, this message translates to:
  /// **'New Scan'**
  String get newScan;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get analysisFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @checkServer.
  ///
  /// In en, this message translates to:
  /// **'Check Server'**
  String get checkServer;

  /// No description provided for @imageDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Image data missing'**
  String get imageDataMissing;

  /// No description provided for @pathAccessRestricted.
  ///
  /// In en, this message translates to:
  /// **'Path access restricted'**
  String get pathAccessRestricted;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String timeDaysAgo(int n);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
