import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/api_endpoints.dart';
import '../models/detection_result.dart';
import '../models/disease.dart';
import '../models/history_item.dart';

/// Core API service for communicating with the AgriScan backend
class ApiService {
  String _baseUrl = AppConfig.apiBaseUrl;

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    return Uri.parse('$_baseUrl$path')
        .replace(queryParameters: queryParams);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── Health ──────────────────────────────────────────────────────────

  /// Check if the backend is reachable
  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(_uri(ApiEndpoints.health))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Detection ───────────────────────────────────────────────────────

  /// Detect plant disease from base64 image
  Future<DetectionResult> detectDisease({
    required String imageBase64,
    double confidence = AppConfig.defaultConfidence,
    bool saveHistory = false,
    String? userId,
    bool trackPrimary = true,
    bool autoDiagnose = true,
    String language = 'en',
  }) async {
    try {
      final body = jsonEncode({
        'image': imageBase64,
        'confidence_threshold': confidence,
        'save_history': saveHistory,
        if (userId != null) 'user_id': userId,
        'track_primary': trackPrimary,
        'auto_diagnose': autoDiagnose,
        'language': language,
      });

      final response = await http
          .post(_uri(ApiEndpoints.detect), headers: _headers, body: body)
          .timeout(AppConfig.detectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DetectionResult.fromJson(data);
    } catch (e) {
      return DetectionResult(success: false, error: e.toString());
    }
  }

  /// Continuous detection (for real-time camera feed)
  Future<DetectionResult> continuousDetect({
    required String imageBase64,
    double confidence = AppConfig.defaultConfidence,
    String language = 'en',
    int minStability = AppConfig.minStabilityFrames,
  }) async {
    try {
      final body = jsonEncode({
        'image': imageBase64,
        'confidence_threshold': confidence,
        'language': language,
        'min_stability': minStability,
      });

      final response = await http
          .post(_uri(ApiEndpoints.detectContinuous),
              headers: _headers, body: body)
          .timeout(AppConfig.detectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DetectionResult.fromJson(data);
    } catch (e) {
      return DetectionResult(success: false, error: e.toString());
    }
  }

  /// Reset the primary detection tracker on backend
  Future<bool> resetTracking() async {
    try {
      final response = await http
          .post(_uri(ApiEndpoints.detectResetTracking), headers: _headers)
          .timeout(AppConfig.apiTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Diagnosis ───────────────────────────────────────────────────────

  /// Get disease diagnosis by name
  Future<DiagnosisResult> getDiagnosis({
    required String diseaseName,
    String language = 'en',
    bool useCache = true,
  }) async {
    try {
      final response = await http
          .get(_uri(ApiEndpoints.diagnose(diseaseName), {
            'language': language,
            'use_cache': useCache.toString(),
          }))
          .timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DiagnosisResult.fromJson(data);
    } catch (e) {
      return DiagnosisResult(success: false, error: e.toString());
    }
  }

  // ─── History ─────────────────────────────────────────────────────────

  /// Get user detection history
  Future<List<HistoryItem>> getHistory(String userId,
      {int limit = AppConfig.historyPageSize, int offset = 0}) async {
    try {
      final response = await http
          .get(_uri(ApiEndpoints.historyGet(userId), {
            'limit': limit.toString(),
            'offset': offset.toString(),
          }))
          .timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['history'] is List) {
        return (data['history'] as List)
            .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Delete a detection from history
  Future<bool> deleteHistory(String detectionId) async {
    try {
      final response = await http
          .delete(_uri(ApiEndpoints.historyDelete(detectionId)))
          .timeout(AppConfig.apiTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Diseases ────────────────────────────────────────────────────────

  /// Get list of all available diseases
  Future<List<String>> getAllDiseases() async {
    try {
      final response = await http
          .get(_uri(ApiEndpoints.diseases))
          .timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['diseases'] is List) {
        return (data['diseases'] as List).map((d) => d.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Search diseases
  Future<List<String>> searchDiseases(String query) async {
    try {
      final response = await http
          .get(_uri(ApiEndpoints.diseasesSearch, {'q': query}))
          .timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['matches'] is List) {
        return (data['matches'] as List).map((d) => d.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Utility ─────────────────────────────────────────────────────────

  /// Convert image bytes to base64 string
  static String bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
