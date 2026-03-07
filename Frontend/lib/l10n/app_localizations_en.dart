// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AgriScan';

  @override
  String get appTagline => 'AI Plant Disease Detection';

  @override
  String get expertCare => '\"Expert care\nfor every\nleaf\"';

  @override
  String get welcomeSubtitle =>
      'Your smart companion for detecting\nplant diseases and protecting your\nfarm';

  @override
  String get register => 'REGISTER';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get email => 'E-mail:';

  @override
  String get password => 'Password:';

  @override
  String get login => 'LOGIN';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get loginSuccessful => 'Login Successful!';

  @override
  String get helloWelcomeBack => 'Hello there!\nWelcome\nBack!';

  @override
  String get welcomeBack => 'Welcome back! You\'re logged in.';

  @override
  String get home => 'Home';

  @override
  String get alerts => 'Alerts';

  @override
  String get analytics => 'Analytics';

  @override
  String get account => 'Account';

  @override
  String get scanPlant => 'Scan Plant';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get scanDescription =>
      'Take a photo or upload an image to detect plant diseases instantly';

  @override
  String get history => 'History';

  @override
  String get diseases => 'Diseases';

  @override
  String get gallery => 'Gallery';

  @override
  String get features => 'Features';

  @override
  String get aiDetection => 'AI Detection';

  @override
  String get aiDetectionDesc => '34 plant diseases recognized with YOLO';

  @override
  String get multilingual => 'Multilingual';

  @override
  String get multilingualDesc => 'English, Hindi, and Kannada support';

  @override
  String get offlineReady => 'Offline Ready';

  @override
  String get offlineReadyDesc => 'Cached diagnoses work without internet';

  @override
  String get smartDiagnosis => 'Smart Diagnosis';

  @override
  String get smartDiagnosisDesc => 'Treatment & prevention recommendations';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get backOnline => 'You\'re back online!';

  @override
  String get youreOffline => 'You\'re offline. Check your connection.';

  @override
  String get scanPlantTitle => 'Scan Plant';

  @override
  String get startingCamera => 'Starting camera...';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get noCameraFound => 'No camera found on this device';

  @override
  String get cameraInitFailed => 'Camera initialization failed';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get analyzingPlant => 'Analyzing plant...';

  @override
  String get analysisReady => 'Analysis ready! Swipe up for details.';

  @override
  String get scanningForDiseases => 'Scanning for diseases...';

  @override
  String get tapToStartScanning => 'Tap the circle to start scanning';

  @override
  String get live => 'LIVE';

  @override
  String get stable => 'STABLE';

  @override
  String get detections => 'detection(s)';

  @override
  String get captureFailed => 'Capture failed';

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String get cannotReachServer => 'Cannot reach backend server';

  @override
  String get serverHealthCheckFailed => 'Server health check failed';

  @override
  String get detectionFailed => 'Detection failed';

  @override
  String get fetchingDiagnosis => 'Fetching diagnosis...';

  @override
  String get fullAnalysis => 'Full Analysis';

  @override
  String get reset => 'Reset';

  @override
  String get description => 'Description';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get symptomsDetected => 'Symptoms Detected';

  @override
  String get organicTreatment => 'Organic Treatment';

  @override
  String get chemicalTreatment => 'Chemical Treatment';

  @override
  String get culturalPractices => 'Cultural Practices';

  @override
  String get prevention => 'Prevention';

  @override
  String get aiCareRecommendations => 'AI Care Recommendations';

  @override
  String get results => 'Results';

  @override
  String get noResults => 'No Results';

  @override
  String get runDetectionFirst => 'Run a detection scan first';

  @override
  String get shareComingSoon => 'Share coming soon';

  @override
  String get healthyPlant => 'Healthy Plant';

  @override
  String get diseaseDetected => 'Disease Detected';

  @override
  String get allDetections => 'All Detections';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get loadingDiagnosis => 'Loading diagnosis...';

  @override
  String get about => 'About';

  @override
  String get severity => 'Severity';

  @override
  String get treatment => 'Treatment';

  @override
  String get organic => '🌿 Organic';

  @override
  String get chemical => '🧪 Chemical';

  @override
  String get cultural => '🌱 Cultural';

  @override
  String get confidence => 'confidence';

  @override
  String get careRecommendations => 'Care Recommendations';

  @override
  String detectedInFrames(int occurrence, int total, int percentage) {
    return 'Detected in $occurrence of $total frames ($percentage%)';
  }

  @override
  String get noHistoryYet => 'No History Yet';

  @override
  String get historySubtitle => 'Your plant scan history will appear here';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirm =>
      'This will remove all scan history. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get searchDiseases => 'Search diseases...';

  @override
  String diseasesCount(int count) {
    return '$count diseases';
  }

  @override
  String get noDiseasesFound => 'No Diseases Found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get diseaseAlert => 'Disease Alert';

  @override
  String get diseaseAlertBody =>
      'Tomato Late Blight detected in your recent scan. Check recommended treatments.';

  @override
  String get plantCareTip => 'Plant Care Tip';

  @override
  String get plantCareTipBody =>
      'Water your crops early morning to reduce fungal disease risk.';

  @override
  String get appUpdate => 'App Update';

  @override
  String get appUpdateBody =>
      'AgriScan v1.1 is available with improved disease detection accuracy.';

  @override
  String get aiConfidenceScore => 'AI Confidence Score';

  @override
  String get confident => 'Confident';

  @override
  String get aiAnalysis => 'AI Analysis — Recent Scan';

  @override
  String get plantHealthStatus => 'Plant Health Status';

  @override
  String get healthy => 'Healthy';

  @override
  String get unhealthy => 'Unhealthy';

  @override
  String get diseaseRisk => 'Disease Risk';

  @override
  String get environmentalMetrics => 'Environmental Metrics';

  @override
  String get light => 'Light';

  @override
  String get humidity => 'Humidity';

  @override
  String get temperature => 'Temperature';

  @override
  String get soilFertility => 'Soil Fertility';

  @override
  String get applyFungicide => 'Apply Fungicide';

  @override
  String get applyFungicideDesc =>
      'Use copper-based fungicide every 7 days until symptoms subside.';

  @override
  String get pruneInfectedLeaves => 'Prune Infected Leaves';

  @override
  String get pruneInfectedLeavesDesc =>
      'Remove and destroy all visibly infected foliage to prevent spread.';

  @override
  String get adjustWatering => 'Adjust Watering';

  @override
  String get adjustWateringDesc =>
      'Switch to drip irrigation. Avoid wetting foliage — water at the base only.';

  @override
  String get improveAirflow => 'Improve Airflow';

  @override
  String get improveAirflowDesc =>
      'Space plants at least 24 inches apart and remove lower branches.';

  @override
  String get increaseSunlight => 'Increase Sunlight Exposure';

  @override
  String get increaseSunlightDesc =>
      'Ensure at least 6-8 hours of direct sunlight daily for optimal recovery.';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get common => 'Common';

  @override
  String get tomato => 'Tomato';

  @override
  String get fungal => 'Fungal';

  @override
  String get severe => 'Severe';

  @override
  String get treatable => 'Treatable';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get detection => 'Detection';

  @override
  String get confidenceThreshold => 'Confidence Threshold';

  @override
  String get saveToHistory => 'Save to History';

  @override
  String get saveToHistoryDesc => 'Automatically save scan results';

  @override
  String get server => 'Server';

  @override
  String get apiBaseUrl => 'API Base URL';

  @override
  String get test => 'Test';

  @override
  String get save => 'Save';

  @override
  String get urlSaved => 'URL saved';

  @override
  String get connectedSuccessfully => '✅ Connected successfully!';

  @override
  String get connectionFailed => '❌ Connection failed';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Switch to dark theme';

  @override
  String get aboutDescription =>
      'AI-powered plant disease detection with multilingual support. Built with Flutter + Flask + YOLO + RAG.';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get onlineAI => 'Online AI (Gemini)';

  @override
  String get cachedData => 'Cached Data';

  @override
  String get knowledgeBase => 'Knowledge Base';

  @override
  String get ragDiagnosis => 'RAG Diagnosis';

  @override
  String get voiceReading => 'Voice Reading';

  @override
  String get voiceReadingDesc => 'Auto-read diagnosis aloud after detection';

  @override
  String get readingDiagnosis => 'Reading diagnosis...';

  @override
  String get tapToListen => 'Tap to listen';

  @override
  String get playing => 'Playing';

  @override
  String get paused => 'Paused';

  @override
  String get voiceStopped => 'Voice stopped';
}
