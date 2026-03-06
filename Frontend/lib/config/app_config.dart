/// AgriScan app configuration
class AppConfig {
  // API
  static const String apiBaseUrl = 'http://localhost:5001/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration detectionTimeout = Duration(seconds: 60);

  // App Info
  static const String appName = 'AgriScan';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'AI Plant Disease Detection';

  // Detection
  static const double defaultConfidence = 0.5;
  static const int maxImageSizeMB = 16;
  static const int continuousDetectionDelayMs = 500;
  static const int minStabilityFrames = 5;

  // History
  static const int historyPageSize = 50;

  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',
    'kn': 'ಕನ್ನಡ',
  };

  static const String defaultLanguage = 'en';
}
