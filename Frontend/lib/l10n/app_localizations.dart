import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('hi'),
    Locale('kn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AgriScan'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Plant Disease Detection'**
  String get appTagline;

  /// No description provided for @expertCare.
  ///
  /// In en, this message translates to:
  /// **'\"Expert care\nfor every\nleaf\"'**
  String get expertCare;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your smart companion for detecting\nplant diseases and protecting your\nfarm'**
  String get welcomeSubtitle;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail:'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password:'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful!'**
  String get loginSuccessful;

  /// No description provided for @helloWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Hello there!\nWelcome\nBack!'**
  String get helloWelcomeBack;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! You\'re logged in.'**
  String get welcomeBack;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @scanPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlant;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @scanDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload an image to detect plant diseases instantly'**
  String get scanDescription;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @diseases.
  ///
  /// In en, this message translates to:
  /// **'Diseases'**
  String get diseases;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @aiDetection.
  ///
  /// In en, this message translates to:
  /// **'AI Detection'**
  String get aiDetection;

  /// No description provided for @aiDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'34 plant diseases recognized with YOLO'**
  String get aiDetectionDesc;

  /// No description provided for @multilingual.
  ///
  /// In en, this message translates to:
  /// **'Multilingual'**
  String get multilingual;

  /// No description provided for @multilingualDesc.
  ///
  /// In en, this message translates to:
  /// **'English, Hindi, and Kannada support'**
  String get multilingualDesc;

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline Ready'**
  String get offlineReady;

  /// No description provided for @offlineReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cached diagnoses work without internet'**
  String get offlineReadyDesc;

  /// No description provided for @smartDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Smart Diagnosis'**
  String get smartDiagnosis;

  /// No description provided for @smartDiagnosisDesc.
  ///
  /// In en, this message translates to:
  /// **'Treatment & prevention recommendations'**
  String get smartDiagnosisDesc;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re back online!'**
  String get backOnline;

  /// No description provided for @youreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your connection.'**
  String get youreOffline;

  /// No description provided for @scanPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlantTitle;

  /// No description provided for @startingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get startingCamera;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraUnavailable;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device'**
  String get noCameraFound;

  /// No description provided for @cameraInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera initialization failed'**
  String get cameraInitFailed;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @analyzingPlant.
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant...'**
  String get analyzingPlant;

  /// No description provided for @analysisReady.
  ///
  /// In en, this message translates to:
  /// **'Analysis ready! Swipe up for details.'**
  String get analysisReady;

  /// No description provided for @scanningForDiseases.
  ///
  /// In en, this message translates to:
  /// **'Scanning for diseases...'**
  String get scanningForDiseases;

  /// No description provided for @tapToStartScanning.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle to start scanning'**
  String get tapToStartScanning;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get stable;

  /// No description provided for @detections.
  ///
  /// In en, this message translates to:
  /// **'detection(s)'**
  String get detections;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed'**
  String get captureFailed;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// No description provided for @cannotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach backend server'**
  String get cannotReachServer;

  /// No description provided for @serverHealthCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Server health check failed'**
  String get serverHealthCheckFailed;

  /// No description provided for @detectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Detection failed'**
  String get detectionFailed;

  /// No description provided for @fetchingDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Fetching diagnosis...'**
  String get fetchingDiagnosis;

  /// No description provided for @fullAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Full Analysis'**
  String get fullAnalysis;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @symptomsDetected.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Detected'**
  String get symptomsDetected;

  /// No description provided for @organicTreatment.
  ///
  /// In en, this message translates to:
  /// **'Organic Treatment'**
  String get organicTreatment;

  /// No description provided for @chemicalTreatment.
  ///
  /// In en, this message translates to:
  /// **'Chemical Treatment'**
  String get chemicalTreatment;

  /// No description provided for @culturalPractices.
  ///
  /// In en, this message translates to:
  /// **'Cultural Practices'**
  String get culturalPractices;

  /// No description provided for @prevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get prevention;

  /// No description provided for @aiCareRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Care Recommendations'**
  String get aiCareRecommendations;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No description provided for @runDetectionFirst.
  ///
  /// In en, this message translates to:
  /// **'Run a detection scan first'**
  String get runDetectionFirst;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon'**
  String get shareComingSoon;

  /// No description provided for @healthyPlant.
  ///
  /// In en, this message translates to:
  /// **'Healthy Plant'**
  String get healthyPlant;

  /// No description provided for @diseaseDetected.
  ///
  /// In en, this message translates to:
  /// **'Disease Detected'**
  String get diseaseDetected;

  /// No description provided for @allDetections.
  ///
  /// In en, this message translates to:
  /// **'All Detections'**
  String get allDetections;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @loadingDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Loading diagnosis...'**
  String get loadingDiagnosis;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'🌿 Organic'**
  String get organic;

  /// No description provided for @chemical.
  ///
  /// In en, this message translates to:
  /// **'🧪 Chemical'**
  String get chemical;

  /// No description provided for @cultural.
  ///
  /// In en, this message translates to:
  /// **'🌱 Cultural'**
  String get cultural;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// No description provided for @careRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Care Recommendations'**
  String get careRecommendations;

  /// No description provided for @detectedInFrames.
  ///
  /// In en, this message translates to:
  /// **'Detected in {occurrence} of {total} frames ({percentage}%)'**
  String detectedInFrames(int occurrence, int total, int percentage);

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No History Yet'**
  String get noHistoryYet;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your plant scan history will appear here'**
  String get historySubtitle;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all scan history. Continue?'**
  String get clearHistoryConfirm;

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

  /// No description provided for @searchDiseases.
  ///
  /// In en, this message translates to:
  /// **'Search diseases...'**
  String get searchDiseases;

  /// No description provided for @diseasesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} diseases'**
  String diseasesCount(int count);

  /// No description provided for @noDiseasesFound.
  ///
  /// In en, this message translates to:
  /// **'No Diseases Found'**
  String get noDiseasesFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @diseaseAlert.
  ///
  /// In en, this message translates to:
  /// **'Disease Alert'**
  String get diseaseAlert;

  /// No description provided for @diseaseAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Tomato Late Blight detected in your recent scan. Check recommended treatments.'**
  String get diseaseAlertBody;

  /// No description provided for @plantCareTip.
  ///
  /// In en, this message translates to:
  /// **'Plant Care Tip'**
  String get plantCareTip;

  /// No description provided for @plantCareTipBody.
  ///
  /// In en, this message translates to:
  /// **'Water your crops early morning to reduce fungal disease risk.'**
  String get plantCareTipBody;

  /// No description provided for @appUpdate.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get appUpdate;

  /// No description provided for @appUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'AgriScan v1.1 is available with improved disease detection accuracy.'**
  String get appUpdateBody;

  /// No description provided for @aiConfidenceScore.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence Score'**
  String get aiConfidenceScore;

  /// No description provided for @confident.
  ///
  /// In en, this message translates to:
  /// **'Confident'**
  String get confident;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis — Recent Scan'**
  String get aiAnalysis;

  /// No description provided for @plantHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Plant Health Status'**
  String get plantHealthStatus;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @unhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get unhealthy;

  /// No description provided for @diseaseRisk.
  ///
  /// In en, this message translates to:
  /// **'Disease Risk'**
  String get diseaseRisk;

  /// No description provided for @environmentalMetrics.
  ///
  /// In en, this message translates to:
  /// **'Environmental Metrics'**
  String get environmentalMetrics;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @soilFertility.
  ///
  /// In en, this message translates to:
  /// **'Soil Fertility'**
  String get soilFertility;

  /// No description provided for @applyFungicide.
  ///
  /// In en, this message translates to:
  /// **'Apply Fungicide'**
  String get applyFungicide;

  /// No description provided for @applyFungicideDesc.
  ///
  /// In en, this message translates to:
  /// **'Use copper-based fungicide every 7 days until symptoms subside.'**
  String get applyFungicideDesc;

  /// No description provided for @pruneInfectedLeaves.
  ///
  /// In en, this message translates to:
  /// **'Prune Infected Leaves'**
  String get pruneInfectedLeaves;

  /// No description provided for @pruneInfectedLeavesDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove and destroy all visibly infected foliage to prevent spread.'**
  String get pruneInfectedLeavesDesc;

  /// No description provided for @adjustWatering.
  ///
  /// In en, this message translates to:
  /// **'Adjust Watering'**
  String get adjustWatering;

  /// No description provided for @adjustWateringDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to drip irrigation. Avoid wetting foliage — water at the base only.'**
  String get adjustWateringDesc;

  /// No description provided for @improveAirflow.
  ///
  /// In en, this message translates to:
  /// **'Improve Airflow'**
  String get improveAirflow;

  /// No description provided for @improveAirflowDesc.
  ///
  /// In en, this message translates to:
  /// **'Space plants at least 24 inches apart and remove lower branches.'**
  String get improveAirflowDesc;

  /// No description provided for @increaseSunlight.
  ///
  /// In en, this message translates to:
  /// **'Increase Sunlight Exposure'**
  String get increaseSunlight;

  /// No description provided for @increaseSunlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure at least 6-8 hours of direct sunlight daily for optimal recovery.'**
  String get increaseSunlightDesc;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get common;

  /// No description provided for @tomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get tomato;

  /// No description provided for @fungal.
  ///
  /// In en, this message translates to:
  /// **'Fungal'**
  String get fungal;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @treatable.
  ///
  /// In en, this message translates to:
  /// **'Treatable'**
  String get treatable;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @detection.
  ///
  /// In en, this message translates to:
  /// **'Detection'**
  String get detection;

  /// No description provided for @confidenceThreshold.
  ///
  /// In en, this message translates to:
  /// **'Confidence Threshold'**
  String get confidenceThreshold;

  /// No description provided for @saveToHistory.
  ///
  /// In en, this message translates to:
  /// **'Save to History'**
  String get saveToHistory;

  /// No description provided for @saveToHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically save scan results'**
  String get saveToHistoryDesc;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @apiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get apiBaseUrl;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @urlSaved.
  ///
  /// In en, this message translates to:
  /// **'URL saved'**
  String get urlSaved;

  /// No description provided for @connectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'✅ Connected successfully!'**
  String get connectedSuccessfully;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection failed'**
  String get connectionFailed;

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

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get darkModeDesc;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-powered plant disease detection with multilingual support. Built with Flutter + Flask + YOLO + RAG.'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @onlineAI.
  ///
  /// In en, this message translates to:
  /// **'Online AI (Gemini)'**
  String get onlineAI;

  /// No description provided for @cachedData.
  ///
  /// In en, this message translates to:
  /// **'Cached Data'**
  String get cachedData;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// No description provided for @ragDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'RAG Diagnosis'**
  String get ragDiagnosis;

  /// No description provided for @voiceReading.
  ///
  /// In en, this message translates to:
  /// **'Voice Reading'**
  String get voiceReading;

  /// No description provided for @voiceReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-read diagnosis aloud after detection'**
  String get voiceReadingDesc;

  /// No description provided for @readingDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Reading diagnosis...'**
  String get readingDiagnosis;

  /// No description provided for @tapToListen.
  ///
  /// In en, this message translates to:
  /// **'Tap to listen'**
  String get tapToListen;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @voiceStopped.
  ///
  /// In en, this message translates to:
  /// **'Voice stopped'**
  String get voiceStopped;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'hi':
      return SHi();
    case 'kn':
      return SKn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
