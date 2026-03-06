import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/detection_result.dart';
import '../models/disease.dart';
import '../providers/app_provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/common_widgets.dart';

/// Screen showing detection results and diagnosis
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _loadingDiagnosis = false;

  @override
  void initState() {
    super.initState();
    _loadDiagnosisIfNeeded();
  }

  Future<void> _loadDiagnosisIfNeeded() async {
    final detection = context.read<DetectionProvider>();
    final app = context.read<AppProvider>();

    if (detection.diagnosis == null && detection.lastResult?.hasPrimary == true) {
      setState(() => _loadingDiagnosis = true);
      await detection.fetchDiagnosis(
        diseaseName: detection.lastResult!.primaryDetection!.className,
        language: app.language,
      );
      if (mounted) setState(() => _loadingDiagnosis = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionProvider>();
    final result = detection.lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No Results',
          subtitle: 'Run a detection scan first',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (detection.capturedImageBytes != null)
              _buildImageCard(detection),
            const SizedBox(height: 16),

            // Primary detection
            if (result.hasPrimary) ...[
              _buildPrimaryDetection(result.primaryDetection!),
              const SizedBox(height: 16),
            ],

            // All detections
            if (result.detections.isNotEmpty) ...[
              _buildDetectionsList(result.detections),
              const SizedBox(height: 16),
            ],

            // Diagnosis
            if (_loadingDiagnosis)
              _buildDiagnosisLoading()
            else if (detection.diagnosis != null)
              _buildDiagnosisCard(detection.diagnosis!),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(DetectionProvider detection) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        detection.capturedImageBytes!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPrimaryDetection(Detection primary) {
    final isHealthy = primary.severityHint == 'healthy';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [AppColors.healthy.withValues(alpha: 0.1), AppColors.healthy.withValues(alpha: 0.05)]
              : [AppColors.highSeverity.withValues(alpha: 0.1), AppColors.mediumSeverity.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy
              ? AppColors.healthy.withValues(alpha: 0.3)
              : AppColors.highSeverity.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isHealthy ? AppColors.healthy : AppColors.highSeverity,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isHealthy ? 'Healthy Plant' : 'Disease Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isHealthy ? AppColors.healthy : AppColors.highSeverity,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            primary.className,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ConfidenceBar(confidence: primary.confidence),
          if (primary.trackingStats != null) ...[
            const SizedBox(height: 8),
            Text(
              'Detected in ${primary.trackingStats!.occurrenceCount} of ${primary.trackingStats!.totalFrames} frames '
              '(${primary.trackingStats!.occurrencePercentage}%)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05);
  }

  Widget _buildDetectionsList(List<Detection> detections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'All Detections',
          icon: Icons.list_rounded,
        ),
        ...detections.asMap().entries.map((entry) {
          final det = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        det.className,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ConfidenceBar(
                        confidence: det.confidence,
                        showLabel: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 150 + entry.key * 60),
              );
        }),
      ],
    );
  }

  Widget _buildDiagnosisLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 12),
          Text(
            'Loading diagnosis...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(Disease disease) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Diagnosis',
          icon: Icons.medical_information_rounded,
        ),

        // Description
        if (disease.description != null) ...[
          _buildInfoCard(
            icon: Icons.info_outline_rounded,
            title: 'About',
            child: Text(
              disease.description!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Severity
        _buildInfoCard(
          icon: Icons.speed_rounded,
          title: 'Severity',
          child: Row(
            children: [
              SeverityBadge(severity: disease.severity),
              const SizedBox(width: 12),
              if (disease.scientificName != null)
                Text(
                  disease.scientificName!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Symptoms
        if (disease.symptoms.isNotEmpty) ...[
          _buildInfoCard(
            icon: Icons.sick_rounded,
            title: 'Symptoms',
            child: _buildBulletList(disease.symptoms),
          ),
          const SizedBox(height: 12),
        ],

        // Treatment
        if (disease.treatment.all.isNotEmpty) ...[
          _buildTreatmentCard(disease.treatment),
          const SizedBox(height: 12),
        ],

        // Prevention
        if (disease.prevention.isNotEmpty) ...[
          _buildInfoCard(
            icon: Icons.shield_rounded,
            title: 'Prevention',
            child: _buildBulletList(disease.prevention),
          ),
          const SizedBox(height: 12),
        ],

        // Care recommendations
        if (disease.careRecommendations.isNotEmpty) ...[
          _buildInfoCard(
            icon: Icons.eco_rounded,
            title: 'Care Recommendations',
            child: _buildBulletList(disease.careRecommendations),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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

  Widget _buildTreatmentCard(Treatment treatment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.healing_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Treatment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          if (treatment.organic.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTreatmentSection('🌿 Organic', treatment.organic),
          ],
          if (treatment.chemical.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildTreatmentSection('🧪 Chemical', treatment.chemical),
          ],
          if (treatment.cultural.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildTreatmentSection('🌱 Cultural', treatment.cultural),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatmentSection(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('  •  ', style: TextStyle(color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
