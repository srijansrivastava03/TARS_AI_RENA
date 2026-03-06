import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sample Plant
            _buildPlantInfoBar(context),
            const SizedBox(height: 20),

            // 2. AI Confidence Score
            _buildConfidenceScore(context),
            const SizedBox(height: 24),

            // 3. AI Analysis
            _buildAiAnalysis(context),
            const SizedBox(height: 24),

            // 4. Plant Health Status (graph)
            _buildPlantHealthStatus(context),
            const SizedBox(height: 24),

            // 5. Environmental Metrics
            _buildEnvironmentalMetrics(context),
            const SizedBox(height: 24),

            // 6. Care Recommendations
            _buildCareRecommendations(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfoBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3C34), Color(0xFF2D5A4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solanum lycopersicum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tomato',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
              ),
            ),
            child: const Text(
              'Common',
              style: TextStyle(
                color: Color(0xFF81C784),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore(BuildContext context) {
    const double confidence = 0.87;
    const int percentage = 87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Confidence Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Circular progress + percentage
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: confidence,
                    strokeWidth: 10,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Confident',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Breakdown
          _buildConfidenceRow('Late Blight', 0.87),
          const SizedBox(height: 8),
          _buildConfidenceRow('Early Blight', 0.09),
          const SizedBox(height: 8),
          _buildConfidenceRow('Healthy', 0.04),
        ],
      ),
    );
  }

  Widget _buildConfidenceRow(String label, double value) {
    final percentage = (value * 100).toInt();
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 0.5
                    ? const Color(0xFF4CAF50)
                    : value > 0.2
                        ? const Color(0xFFFFC107)
                        : AppColors.textHint,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiAnalysis(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3C34).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFF1A3C34), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'AI Analysis — Recent Scan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '2 min ago',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Plant image + basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_florist_rounded,
                    color: AppColors.primary, size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tomato — Late Blight',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Phytophthora infestans',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTag('Fungal', const Color(0xFFF44336)),
                        const SizedBox(width: 6),
                        _buildTag('Severe', const Color(0xFFFF9800)),
                        const SizedBox(width: 6),
                        _buildTag('Treatable', const Color(0xFF4CAF50)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Symptoms
          const Text(
            'Symptoms Detected',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildSymptomItem('Dark brown lesions on leaves'),
          _buildSymptomItem('White mold on leaf undersides'),
          _buildSymptomItem('Water-soaked spots on stems'),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildSymptomItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFF44336)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 4. Plant Health Status — donut chart
  // ──────────────────────────────────────────────
  Widget _buildPlantHealthStatus(BuildContext context) {
    const double healthy = 0.31;
    const double unhealthy = 0.69;
    const double diseaseRisk = 0.74;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.monitor_heart_rounded,
                    color: Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Plant Health Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut chart
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _HealthDonutPainter(
                  healthy: healthy,
                  unhealthy: unhealthy,
                  diseaseRisk: diseaseRisk,
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('31%',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50))),
                      Text('Healthy',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFF4CAF50), 'Healthy  31%'),
              const SizedBox(width: 20),
              _buildLegendDot(const Color(0xFFFF9800), 'Unhealthy  69%'),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: _buildLegendDot(
                const Color(0xFFF44336), 'Disease Risk  74%',
                isOutline: true),
          ),

          const SizedBox(height: 18),
          // Disease risk bar
          const Text('Disease Risk',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: diseaseRisk,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: const Color(0xFFF44336), width: 2),
                    color: const Color(0xFFF44336).withValues(alpha: 0.15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('74%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF44336))),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, {bool isOutline = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color,
            border: isOutline ? Border.all(color: color, width: 2) : null,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // 5. Environmental Metrics
  // ──────────────────────────────────────────────
  Widget _buildEnvironmentalMetrics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_outlined,
                    color: Color(0xFF2196F3), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Environmental Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricTile(
                Icons.wb_sunny_rounded,
                'Light',
                '72%',
                const Color(0xFFFFC107),
                0.72,
              ),
              const SizedBox(width: 12),
              _buildMetricTile(
                Icons.water_drop_rounded,
                'Humidity',
                '65%',
                const Color(0xFF2196F3),
                0.65,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricTile(
                Icons.thermostat_rounded,
                'Temperature',
                '78°F',
                const Color(0xFFFF5722),
                0.78,
              ),
              const SizedBox(width: 12),
              _buildMetricTile(
                Icons.grass_rounded,
                'Soil Fertility',
                '54%',
                const Color(0xFF8BC34A),
                0.54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      IconData icon, String label, String value, Color color, double progress) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const Spacer(),
                Text(value,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 6. Care Recommendations
  // ──────────────────────────────────────────────
  Widget _buildCareRecommendations(BuildContext context) {
    final recommendations = [
      _CareItem(
        icon: Icons.science_rounded,
        title: 'Apply Fungicide',
        description:
            'Use copper-based fungicide every 7 days until symptoms subside.',
        priority: 'High',
        priorityColor: const Color(0xFFF44336),
      ),
      _CareItem(
        icon: Icons.content_cut_rounded,
        title: 'Prune Infected Leaves',
        description:
            'Remove and destroy all visibly infected foliage to prevent spread.',
        priority: 'High',
        priorityColor: const Color(0xFFF44336),
      ),
      _CareItem(
        icon: Icons.water_drop_rounded,
        title: 'Adjust Watering',
        description:
            'Switch to drip irrigation. Avoid wetting foliage — water at the base only.',
        priority: 'Medium',
        priorityColor: const Color(0xFFFF9800),
      ),
      _CareItem(
        icon: Icons.air_rounded,
        title: 'Improve Airflow',
        description:
            'Space plants at least 24 inches apart and remove lower branches.',
        priority: 'Medium',
        priorityColor: const Color(0xFFFF9800),
      ),
      _CareItem(
        icon: Icons.wb_sunny_outlined,
        title: 'Increase Sunlight Exposure',
        description:
            'Ensure at least 6-8 hours of direct sunlight daily for optimal recovery.',
        priority: 'Low',
        priorityColor: const Color(0xFF4CAF50),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tips_and_updates_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Care Recommendations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((item) => _buildCareCard(item)),
        ],
      ),
    );
  }

  Widget _buildCareCard(_CareItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.priorityColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.priorityColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 18, color: item.priorityColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.priority,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.priorityColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Custom painter for the Health donut chart
// ──────────────────────────────────────────────
class _HealthDonutPainter extends CustomPainter {
  final double healthy;
  final double unhealthy;
  final double diseaseRisk;

  _HealthDonutPainter({
    required this.healthy,
    required this.unhealthy,
    required this.diseaseRisk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 22.0;
    const startAngle = -math.pi / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Healthy arc (green)
    final healthyPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final healthySweep = 2 * math.pi * healthy;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      healthySweep,
      false,
      healthyPaint,
    );

    // Unhealthy arc (orange)
    final unhealthyPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + healthySweep,
      2 * math.pi * unhealthy,
      false,
      unhealthyPaint,
    );

    // Disease risk outline ring (red dashed-style outline)
    final riskPaint = Paint()
      ..color = const Color(0xFFF44336)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final riskRadius = radius + strokeWidth / 2 + 4;
    final riskSweep = 2 * math.pi * diseaseRisk;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: riskRadius),
      startAngle,
      riskSweep,
      false,
      riskPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CareItem {
  final IconData icon;
  final String title;
  final String description;
  final String priority;
  final Color priorityColor;

  _CareItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
    required this.priorityColor,
  });
}
