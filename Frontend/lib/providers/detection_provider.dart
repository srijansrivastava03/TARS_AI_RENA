import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/detection_result.dart';
import '../models/disease.dart';
import '../services/api_service.dart';

/// Possible states for detection
enum DetectionState { idle, detecting, success, error }

/// Provider that manages detection logic & state
class DetectionProvider extends ChangeNotifier {
  final ApiService _api;

  DetectionProvider(this._api);

  // ─── State ─────────────────────────────────────────────────────────
  DetectionState _state = DetectionState.idle;
  DetectionResult? _lastResult;
  Disease? _diagnosis;
  String? _errorMessage;
  Uint8List? _capturedImageBytes;
  bool _isServerOnline = false;

  // ─── Getters ───────────────────────────────────────────────────────
  DetectionState get state => _state;
  DetectionResult? get lastResult => _lastResult;
  Disease? get diagnosis => _diagnosis;
  String? get errorMessage => _errorMessage;
  Uint8List? get capturedImageBytes => _capturedImageBytes;
  bool get isServerOnline => _isServerOnline;
  bool get isDetecting => _state == DetectionState.detecting;
  bool get hasResult => _state == DetectionState.success && _lastResult != null;

  // ─── Server Health ─────────────────────────────────────────────────
  Future<bool> checkServer() async {
    _isServerOnline = await _api.healthCheck();
    notifyListeners();
    return _isServerOnline;
  }

  // ─── Detect from bytes ─────────────────────────────────────────────
  Future<DetectionResult?> detectFromBytes({
    required Uint8List imageBytes,
    double confidence = 0.5,
    String? userId,
    bool saveHistory = false,
    String language = 'en',
  }) async {
    _state = DetectionState.detecting;
    _errorMessage = null;
    _capturedImageBytes = imageBytes;
    notifyListeners();

    final base64Image = base64Encode(imageBytes);

    final result = await _api.detectDisease(
      imageBase64: base64Image,
      confidence: confidence,
      saveHistory: saveHistory,
      userId: userId,
      language: language,
    );

    _lastResult = result;

    if (result.success) {
      _state = DetectionState.success;

      // Extract diagnosis if returned inline
      if (result.diagnosis != null) {
        _diagnosis = Disease.fromJson(result.diagnosis!);
      }
    } else {
      _state = DetectionState.error;
      _errorMessage = result.error ?? 'Detection failed';
    }

    notifyListeners();
    return result;
  }

  // ─── Fetch diagnosis separately ────────────────────────────────────
  Future<Disease?> fetchDiagnosis({
    required String diseaseName,
    String language = 'en',
  }) async {
    final result = await _api.getDiagnosis(
      diseaseName: diseaseName,
      language: language,
    );

    if (result.success && result.disease != null) {
      _diagnosis = result.disease;
      notifyListeners();
      return result.disease;
    }
    return null;
  }

  // ─── Reset ─────────────────────────────────────────────────────────
  void reset() {
    _state = DetectionState.idle;
    _lastResult = null;
    _diagnosis = null;
    _errorMessage = null;
    _capturedImageBytes = null;
    notifyListeners();
  }

  Future<void> resetTracking() async {
    await _api.resetTracking();
  }
}
