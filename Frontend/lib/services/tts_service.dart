import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/disease.dart';

/// Text-to-Speech service for reading out diagnosis results
/// Supports English, Hindi, and Kannada
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  // ─── State ─────────────────────────────────────────────────────────
  TtsState _state = TtsState.stopped;
  TtsState get state => _state;

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // Callbacks for UI updates
  void Function(TtsState state)? onStateChanged;

  // ─── Language → TTS locale mapping ─────────────────────────────────
  static const Map<String, String> _languageMap = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'kn': 'kn-IN',
  };

  // ─── Init ──────────────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setSpeechRate(0.45); // Slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _state = TtsState.playing;
      onStateChanged?.call(_state);
    });

    _tts.setCompletionHandler(() {
      _state = TtsState.stopped;
      onStateChanged?.call(_state);
    });

    _tts.setPauseHandler(() {
      _state = TtsState.paused;
      onStateChanged?.call(_state);
    });

    _tts.setContinueHandler(() {
      _state = TtsState.playing;
      onStateChanged?.call(_state);
    });

    _tts.setErrorHandler((msg) {
      _state = TtsState.stopped;
      onStateChanged?.call(_state);
    });

    _isInitialized = true;
  }

  // ─── Set language ──────────────────────────────────────────────────
  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    final ttsLocale = _languageMap[langCode] ?? 'en-US';
    await _tts.setLanguage(ttsLocale);
  }

  // ─── Build readable text from Disease ──────────────────────────────
  String buildDiagnosisText({
    required Disease disease,
    required String langCode,
    String? primaryClassName,
    bool isHealthy = false,
  }) {
    final buf = StringBuffer();

    switch (langCode) {
      case 'hi':
        buf.writeln(_buildHindiText(disease, primaryClassName, isHealthy));
        break;
      case 'kn':
        buf.writeln(_buildKannadaText(disease, primaryClassName, isHealthy));
        break;
      default:
        buf.writeln(_buildEnglishText(disease, primaryClassName, isHealthy));
    }

    return buf.toString();
  }

  String _buildEnglishText(Disease disease, String? className, bool isHealthy) {
    final buf = StringBuffer();

    if (isHealthy) {
      buf.writeln('Good news! Your plant appears healthy.');
      buf.writeln('No diseases were detected.');
      return buf.toString();
    }

    buf.writeln('Disease detected: ${className ?? disease.name}.');

    if (disease.description != null && disease.description!.isNotEmpty) {
      buf.writeln(disease.description!);
    }

    buf.writeln('Severity: ${disease.severity}.');

    if (disease.symptoms.isNotEmpty) {
      buf.writeln('Symptoms include: ${disease.symptoms.join(", ")}.');
    }

    if (disease.treatment.all.isNotEmpty) {
      buf.writeln('Recommended treatment:');
      if (disease.treatment.organic.isNotEmpty) {
        buf.writeln('Organic: ${disease.treatment.organic.join(", ")}.');
      }
      if (disease.treatment.chemical.isNotEmpty) {
        buf.writeln('Chemical: ${disease.treatment.chemical.join(", ")}.');
      }
      if (disease.treatment.cultural.isNotEmpty) {
        buf.writeln('Cultural: ${disease.treatment.cultural.join(", ")}.');
      }
    }

    if (disease.prevention.isNotEmpty) {
      buf.writeln('Prevention: ${disease.prevention.join(", ")}.');
    }

    if (disease.careRecommendations.isNotEmpty) {
      buf.writeln(
          'Care recommendations: ${disease.careRecommendations.join(", ")}.');
    }

    return buf.toString();
  }

  String _buildHindiText(Disease disease, String? className, bool isHealthy) {
    final buf = StringBuffer();

    if (isHealthy) {
      buf.writeln('अच्छी खबर! आपका पौधा स्वस्थ दिखता है।');
      buf.writeln('कोई बीमारी नहीं पाई गई।');
      return buf.toString();
    }

    buf.writeln('बीमारी का पता चला: ${className ?? disease.name}।');

    if (disease.description != null && disease.description!.isNotEmpty) {
      buf.writeln(disease.description!);
    }

    buf.writeln('गंभीरता: ${disease.severity}।');

    if (disease.symptoms.isNotEmpty) {
      buf.writeln('लक्षण: ${disease.symptoms.join(", ")}।');
    }

    if (disease.treatment.all.isNotEmpty) {
      buf.writeln('सुझाया गया उपचार:');
      if (disease.treatment.organic.isNotEmpty) {
        buf.writeln('जैविक: ${disease.treatment.organic.join(", ")}।');
      }
      if (disease.treatment.chemical.isNotEmpty) {
        buf.writeln('रासायनिक: ${disease.treatment.chemical.join(", ")}।');
      }
      if (disease.treatment.cultural.isNotEmpty) {
        buf.writeln('सांस्कृतिक: ${disease.treatment.cultural.join(", ")}।');
      }
    }

    if (disease.prevention.isNotEmpty) {
      buf.writeln('रोकथाम: ${disease.prevention.join(", ")}।');
    }

    if (disease.careRecommendations.isNotEmpty) {
      buf.writeln('देखभाल की सिफारिशें: ${disease.careRecommendations.join(", ")}।');
    }

    return buf.toString();
  }

  String _buildKannadaText(Disease disease, String? className, bool isHealthy) {
    final buf = StringBuffer();

    if (isHealthy) {
      buf.writeln('ಒಳ್ಳೆಯ ಸುದ್ದಿ! ನಿಮ್ಮ ಸಸ್ಯವು ಆರೋಗ್ಯಕರವಾಗಿ ಕಾಣುತ್ತಿದೆ.');
      buf.writeln('ಯಾವುದೇ ರೋಗ ಪತ್ತೆಯಾಗಿಲ್ಲ.');
      return buf.toString();
    }

    buf.writeln('ರೋಗ ಪತ್ತೆಯಾಗಿದೆ: ${className ?? disease.name}.');

    if (disease.description != null && disease.description!.isNotEmpty) {
      buf.writeln(disease.description!);
    }

    buf.writeln('ತೀವ್ರತೆ: ${disease.severity}.');

    if (disease.symptoms.isNotEmpty) {
      buf.writeln('ಲಕ್ಷಣಗಳು: ${disease.symptoms.join(", ")}.');
    }

    if (disease.treatment.all.isNotEmpty) {
      buf.writeln('ಶಿಫಾರಸು ಮಾಡಿದ ಚಿಕಿತ್ಸೆ:');
      if (disease.treatment.organic.isNotEmpty) {
        buf.writeln('ಸಾವಯವ: ${disease.treatment.organic.join(", ")}.');
      }
      if (disease.treatment.chemical.isNotEmpty) {
        buf.writeln('ರಾಸಾಯನಿಕ: ${disease.treatment.chemical.join(", ")}.');
      }
      if (disease.treatment.cultural.isNotEmpty) {
        buf.writeln('ಸಾಂಸ್ಕೃತಿಕ: ${disease.treatment.cultural.join(", ")}.');
      }
    }

    if (disease.prevention.isNotEmpty) {
      buf.writeln('ತಡೆಗಟ್ಟುವಿಕೆ: ${disease.prevention.join(", ")}.');
    }

    if (disease.careRecommendations.isNotEmpty) {
      buf.writeln('ಆರೈಕೆ ಶಿಫಾರಸುಗಳು: ${disease.careRecommendations.join(", ")}.');
    }

    return buf.toString();
  }

  // ─── Playback controls ─────────────────────────────────────────────
  Future<void> speak(String text) async {
    await initialize();
    if (_state == TtsState.playing) {
      await stop();
    }
    _state = TtsState.playing;
    onStateChanged?.call(_state);
    await _tts.speak(text);
  }

  Future<void> pause() async {
    if (_state == TtsState.playing) {
      await _tts.pause();
      _state = TtsState.paused;
      onStateChanged?.call(_state);
    }
  }

  Future<void> resume() async {
    if (_state == TtsState.paused) {
      // flutter_tts doesn't have a native resume on all platforms
      // pause/resume is supported on iOS and some Android versions
      _state = TtsState.playing;
      onStateChanged?.call(_state);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = TtsState.stopped;
    onStateChanged?.call(_state);
  }

  Future<void> dispose() async {
    await stop();
  }

  // ─── Convenience: speak a full diagnosis ───────────────────────────
  Future<void> speakDiagnosis({
    required Disease disease,
    required String langCode,
    String? primaryClassName,
    bool isHealthy = false,
  }) async {
    await setLanguage(langCode);
    final text = buildDiagnosisText(
      disease: disease,
      langCode: langCode,
      primaryClassName: primaryClassName,
      isHealthy: isHealthy,
    );
    await speak(text);
  }
}

enum TtsState { playing, paused, stopped }
