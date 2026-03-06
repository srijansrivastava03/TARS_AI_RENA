import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/detection_result.dart';
import '../models/disease.dart';
import '../providers/app_provider.dart';
import '../providers/detection_provider.dart';

/// Full-screen camera scan screen with real-time detection,
/// bounding box overlay, and RAG diagnosis panel (VESIRE-inspired).
class ScanScreen extends StatefulWidget {
  final VoidCallback onResultReady;

  const ScanScreen({super.key, required this.onResultReady});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCameraError = false;
  String? _cameraErrorMsg;

  // Continuous detection
  Timer? _scanTimer;
  bool _isDetectionActive = false;
  bool _frameInFlight = false;
  DetectionResult? _latestDetection;

  // RAG diagnosis
  Disease? _currentDiagnosis;
  String? _diagnosisSource;
  String? _lastDiagnosedDisease;
  bool _isDiagnosing = false;
  bool _analysisReady = false;

  // Flash
  bool _isFlashOn = false;

  // Capture
  bool _isCapturing = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopDetection();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopDetection();
      _cameraController?.dispose();
      _cameraController = null;
      if (mounted) setState(() => _isCameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ─── Camera ────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMsg = 'No camera found on this device';
        });
        return;
      }
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _isCameraError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMsg = 'Camera initialization failed';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      await _cameraController!.setFlashMode(_isFlashOn ? FlashMode.off : FlashMode.torch);
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  // ─── Real-time Detection Loop ──────────────────────────────────────

  void _startDetection() {
    if (_isDetectionActive) return;
    setState(() {
      _isDetectionActive = true;
      _latestDetection = null;
      _currentDiagnosis = null;
      _diagnosisSource = null;
      _lastDiagnosedDisease = null;
      _analysisReady = false;
    });
    // Reset backend tracker
    context.read<DetectionProvider>().resetTracking();
    _scanTimer = Timer.periodic(
      Duration(milliseconds: AppConfig.continuousDetectionDelayMs),
      (_) => _processFrame(),
    );
  }

  void _stopDetection() {
    _scanTimer?.cancel();
    _scanTimer = null;
    if (mounted) {
      setState(() => _isDetectionActive = false);
    }
  }

  Future<void> _processFrame() async {
    if (_frameInFlight ||
        !_isCameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    _frameInFlight = true;
    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      final detection = context.read<DetectionProvider>();
      final app = context.read<AppProvider>();

      final result = await detection.continuousDetectFromBytes(
        imageBytes: bytes,
        confidence: app.confidenceThreshold,
        language: app.language,
        minStability: AppConfig.minStabilityFrames,
      );

      if (!mounted) return;

      if (result != null && result.hasDetections) {
        setState(() => _latestDetection = result);

        // Auto-trigger diagnosis when primary is stable
        final primary = result.primaryDetection ?? result.detections.first;
        final isStable = primary.trackingStats?.isStable ?? false;
        if (isStable &&
            primary.className != _lastDiagnosedDisease &&
            !_isDiagnosing) {
          _fetchDiagnosis(primary.className);
        }
      } else {
        setState(() => _latestDetection = null);
      }
    } catch (_) {
    } finally {
      _frameInFlight = false;
    }
  }

  // ─── RAG Diagnosis ─────────────────────────────────────────────────

  Future<void> _fetchDiagnosis(String diseaseName) async {
    _isDiagnosing = true;
    _lastDiagnosedDisease = diseaseName;

    try {
      final app = context.read<AppProvider>();
      final detection = context.read<DetectionProvider>();
      final disease = await detection.fetchDiagnosis(
        diseaseName: diseaseName,
        language: app.language,
      );
      if (!mounted) return;
      setState(() {
        _currentDiagnosis = disease;
        _diagnosisSource = 'rag';
        _analysisReady = disease != null;
      });
    } catch (_) {
    } finally {
      _isDiagnosing = false;
    }
  }

  // ─── Capture / Gallery ─────────────────────────────────────────────

  Future<void> _captureAndAnalyze() async {
    if (_isCapturing || !_isCameraReady || _cameraController == null) return;
    setState(() => _isCapturing = true);
    _stopDetection();
    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      await _runFullDetection(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _isCapturing = true);
        _stopDetection();
        final bytes = await picked.readAsBytes();
        await _runFullDetection(bytes);
        if (mounted) setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _runFullDetection(Uint8List bytes) async {
    final app = context.read<AppProvider>();
    final detection = context.read<DetectionProvider>();
    final result = await detection.detectFromBytes(
      imageBytes: bytes,
      confidence: app.confidenceThreshold,
      userId: app.userId,
      saveHistory: app.saveHistory,
      language: app.language,
    );
    if (result != null && result.success && mounted) {
      widget.onResultReady();
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isCameraReady && _cameraController != null)
            _buildCameraPreview()
          else if (_isCameraError)
            _buildCameraError()
          else
            _buildCameraLoading(),

          // Bounding boxes overlay
          if (_latestDetection != null &&
              _latestDetection!.hasDetections &&
              _isCameraReady)
            Positioned.fill(
              child: CustomPaint(
                painter: _BoundingBoxPainter(
                  detections: _latestDetection!.detections,
                ),
              ),
            ),

          // Detection status badge (top center)
          if (_latestDetection != null && _latestDetection!.hasDetections)
            _buildDetectionBadge(),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),

          // Diagnosis panel (draggable bottom sheet)
          if (_analysisReady && _currentDiagnosis != null)
            _buildDiagnosisSheet(),

          // Diagnosing spinner
          if (_isDiagnosing && !_analysisReady)
            _buildDiagnosingIndicator(),

          // Capture overlay
          if (_isCapturing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Analyzing plant...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Camera Views ──────────────────────────────────────────────────

  Widget _buildCameraPreview() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildCameraLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Starting camera...', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCameraError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              _cameraErrorMsg ?? 'Camera unavailable',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Pick from Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Detection Badge ──────────────────────────────────────────────

  Widget _buildDetectionBadge() {
    final primary = _latestDetection!.primaryDetection ?? _latestDetection!.detections.first;
    final isStable = primary.trackingStats?.isStable ?? false;
    final confidencePct = (primary.confidence * 100).toStringAsFixed(0);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isStable
              ? Colors.green.withValues(alpha: 0.9)
              : Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isStable ? Icons.check_circle : Icons.search, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${_latestDetection!.detections.length} detection(s) • $confidencePct%${isStable ? ' • STABLE' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Scan Plant',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Flash toggle
            if (_isCameraReady)
              GestureDetector(
                onTap: _toggleFlash,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Scanning indicator
            if (_isDetectionActive && _isCameraReady)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 6),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Controls ──────────────────────────────────────────────

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status text
            Text(
              _analysisReady
                  ? 'Analysis ready! Swipe up for details.'
                  : _isDetectionActive
                      ? 'Scanning for diseases...'
                      : 'Tap the circle to start scanning',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery
                _ControlButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: _isCapturing ? null : _pickFromGallery,
                ),

                // Start / Stop / Capture toggle
                GestureDetector(
                  onTap: _isCapturing
                      ? null
                      : () {
                          if (_analysisReady) {
                            // Full capture & navigate to results
                            _captureAndAnalyze();
                          } else if (_isDetectionActive) {
                            _stopDetection();
                          } else {
                            _startDetection();
                          }
                        },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: _analysisReady
                              ? Colors.blue.withValues(alpha: 0.5)
                              : _isDetectionActive
                                  ? Colors.red.withValues(alpha: 0.4)
                                  : Colors.green.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _analysisReady
                            ? Colors.blue.shade600
                            : _isDetectionActive
                                ? Colors.red.shade600
                                : const Color(0xFF4CAF50),
                      ),
                      child: _analysisReady
                          ? const Icon(Icons.camera_rounded, color: Colors.white, size: 32)
                          : _isDetectionActive
                              ? const Icon(Icons.stop, color: Colors.white, size: 32)
                              : null,
                    ),
                  ),
                ),

                // Reset
                _ControlButton(
                  icon: Icons.refresh_rounded,
                  label: 'Reset',
                  onTap: () {
                    _stopDetection();
                    context.read<DetectionProvider>().resetTracking();
                    setState(() {
                      _latestDetection = null;
                      _currentDiagnosis = null;
                      _diagnosisSource = null;
                      _lastDiagnosedDisease = null;
                      _analysisReady = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Diagnosis Sheet ──────────────────────────────────────────────

  Widget _buildDiagnosisSheet() {
    final disease = _currentDiagnosis!;
    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.12, 0.4, 0.75],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4))],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Peek row: disease name + severity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _severityColor(disease.severity).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.bug_report_rounded, color: _severityColor(disease.severity), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disease.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                          ),
                          if (disease.scientificName != null)
                            Text(
                              disease.scientificName!,
                              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                    _SeverityBadge(severity: disease.severity),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Source badge
              if (_diagnosisSource != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SourceBadge(source: _diagnosisSource!),
                ),
              const SizedBox(height: 12),
              // Description
              if (disease.description != null && disease.description!.isNotEmpty)
                _DiagnosisSection(
                  title: 'Description',
                  icon: Icons.info_outline,
                  child: Text(
                    disease.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),
                ),
              // Symptoms
              if (disease.symptoms.isNotEmpty)
                _DiagnosisSection(
                  title: 'Symptoms',
                  icon: Icons.medical_services_outlined,
                  child: _BulletList(items: disease.symptoms),
                ),
              // AI Care Recommendations
              if (disease.careRecommendations.isNotEmpty)
                _DiagnosisSection(
                  title: 'AI Care Recommendations',
                  icon: Icons.auto_awesome,
                  isAI: true,
                  child: _BulletList(items: disease.careRecommendations, isAI: true),
                ),
              // Treatment – organic
              if (disease.treatment.organic.isNotEmpty)
                _DiagnosisSection(
                  title: 'Organic Treatment',
                  icon: Icons.eco_outlined,
                  child: _BulletList(items: disease.treatment.organic),
                ),
              // Treatment – chemical
              if (disease.treatment.chemical.isNotEmpty)
                _DiagnosisSection(
                  title: 'Chemical Treatment',
                  icon: Icons.science_outlined,
                  child: _BulletList(items: disease.treatment.chemical),
                ),
              // Treatment – cultural
              if (disease.treatment.cultural.isNotEmpty)
                _DiagnosisSection(
                  title: 'Cultural Practices',
                  icon: Icons.agriculture_outlined,
                  child: _BulletList(items: disease.treatment.cultural),
                ),
              // Prevention
              if (disease.prevention.isNotEmpty)
                _DiagnosisSection(
                  title: 'Prevention',
                  icon: Icons.shield_outlined,
                  child: _BulletList(items: disease.prevention),
                ),
              // Full analysis button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: ElevatedButton.icon(
                  onPressed: _captureAndAnalyze,
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Full Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiagnosingIndicator() {
    return Positioned(
      bottom: 160,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 10),
              Text('Fetching diagnosis...', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  static Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════════

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _ScanScreenState._severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  Color get _color {
    switch (source) {
      case 'online_llm':
        return Colors.purple.shade600;
      case 'cache':
        return Colors.blue.shade600;
      case 'knowledge_base':
        return Colors.orange.shade600;
      default:
        return Colors.teal.shade600;
    }
  }

  String get _label {
    switch (source) {
      case 'online_llm':
        return 'Online AI (Gemini)';
      case 'cache':
        return 'Cached Data';
      case 'knowledge_base':
        return 'Knowledge Base';
      default:
        return 'RAG Diagnosis';
    }
  }

  IconData get _icon {
    switch (source) {
      case 'online_llm':
        return Icons.cloud_done;
      case 'cache':
        return Icons.storage;
      case 'knowledge_base':
        return Icons.book;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, color: _color, size: 14),
              const SizedBox(width: 6),
              Text(_label, style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosisSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isAI;

  const _DiagnosisSection({required this.title, required this.icon, required this.child, this.isAI = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAI ? Colors.purple.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAI ? Colors.purple.shade200 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isAI ? Colors.purple.shade600 : const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isAI ? Colors.purple.shade900 : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool isAI;

  const _BulletList({required this.items, this.isAI = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isAI ? Colors.purple.shade600 : const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Bounding Box Painter
// ═══════════════════════════════════════════════════════════════════════

class _BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;

  _BoundingBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      final centerX = detection.boundingBox.x;
      final centerY = detection.boundingBox.y;
      final boxW = detection.boundingBox.width;
      final boxH = detection.boundingBox.height;

      final left = (centerX - boxW / 2) * size.width;
      final top = (centerY - boxH / 2) * size.height;
      final right = (centerX + boxW / 2) * size.width;
      final bottom = (centerY + boxH / 2) * size.height;

      // Box
      final boxPaint = Paint()
        ..color = const Color(0xFF00FF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), boxPaint);

      // Label
      final label = '${detection.className} ${(detection.confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelBg = Paint()..color = const Color(0xFF00FF00);
      canvas.drawRect(
        Rect.fromLTWH(left, top - 24, textPainter.width + 12, 24),
        labelBg,
      );
      textPainter.paint(canvas, Offset(left + 6, top - 22));
    }
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) => true;
}
