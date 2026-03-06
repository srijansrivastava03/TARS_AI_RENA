import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

/// Global app settings provider
class AppProvider extends ChangeNotifier {
  // ─── State ─────────────────────────────────────────────────────────
  String _userId = '';
  String _language = AppConfig.defaultLanguage;
  String _apiBaseUrl = AppConfig.apiBaseUrl;
  bool _darkMode = false;
  double _confidenceThreshold = AppConfig.defaultConfidence;
  bool _saveHistory = true;
  bool _isInitialized = false;

  // ─── Getters ───────────────────────────────────────────────────────
  String get userId => _userId;
  String get language => _language;
  String get apiBaseUrl => _apiBaseUrl;
  bool get darkMode => _darkMode;
  double get confidenceThreshold => _confidenceThreshold;
  bool get saveHistory => _saveHistory;
  bool get isInitialized => _isInitialized;

  String get languageName =>
      AppConfig.supportedLanguages[_language] ?? 'English';

  // ─── Init ──────────────────────────────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getString('user_id') ?? const Uuid().v4();
    _language = prefs.getString('language') ?? AppConfig.defaultLanguage;
    _apiBaseUrl = prefs.getString('api_base_url') ?? AppConfig.apiBaseUrl;
    _darkMode = prefs.getBool('dark_mode') ?? false;
    _confidenceThreshold =
        prefs.getDouble('confidence_threshold') ?? AppConfig.defaultConfidence;
    _saveHistory = prefs.getBool('save_history') ?? true;

    // Persist userId if new
    if (!prefs.containsKey('user_id')) {
      await prefs.setString('user_id', _userId);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ─── Setters ───────────────────────────────────────────────────────
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String url) async {
    _apiBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setConfidenceThreshold(double value) async {
    _confidenceThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('confidence_threshold', value);
    notifyListeners();
  }

  Future<void> setSaveHistory(bool value) async {
    _saveHistory = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('save_history', value);
    notifyListeners();
  }
}
