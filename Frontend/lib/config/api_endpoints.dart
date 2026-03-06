/// All API endpoint paths
class ApiEndpoints {
  static const String health = '/health';
  static const String info = '/info';
  static const String models = '/models';

  // Detection
  static const String detect = '/detect';
  static const String detectBatch = '/detect/batch';
  static const String detectContinuous = '/detect/continuous';
  static const String detectResetTracking = '/detect/reset-tracking';

  // Diagnosis
  static String diagnose(String diseaseName) => '/diagnose/$diseaseName';
  static const String diagnosePost = '/diagnose';

  // History
  static const String historySave = '/history';
  static String historyGet(String userId) => '/history/$userId';
  static String historyDelete(String detectionId) => '/history/$detectionId';

  // Diseases
  static const String diseases = '/diseases';
  static const String diseasesSearch = '/diseases/search';
}
