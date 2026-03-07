import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onScanTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onDiseasesTap;

  const HomeScreen({
    super.key,
    required this.onScanTap,
    required this.onHistoryTap,
    required this.onDiseasesTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check server status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetectionProvider>().checkServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionProvider>();
    final app = context.watch<AppProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(app, detection),
              const SizedBox(height: 28),

              // Hero scan card
              _buildScanCard(),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 28),

              // Features section
              SectionHeader(
                title: S.of(context).features,
                icon: Icons.star_rounded,
              ),
              _buildFeaturesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider app, DetectionProvider detection) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌿 ${S.of(context).appName}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).appTagline,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Language toggle
        _buildLanguageChip(app),
        const SizedBox(width: 8),
        // Server status
        GestureDetector(
          onTap: () => detection.checkServer(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: detection.isServerOnline
                  ? AppColors.healthy.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusDot(isOnline: detection.isServerOnline),
                const SizedBox(width: 6),
                Text(
                  detection.isServerOnline ? S.of(context).online : S.of(context).offline,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: detection.isServerOnline
                        ? AppColors.healthy
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildLanguageChip(AppProvider app) {
    final languages = AppConfig.supportedLanguages;
    final keys = languages.keys.toList();
    final currentIndex = keys.indexOf(app.language);
    final currentLabel = languages[app.language] ?? 'EN';

    return GestureDetector(
      onTap: () {
        final nextIndex = (currentIndex + 1) % keys.length;
        app.setLanguage(keys[nextIndex]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              currentLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard() {
    return GestureDetector(
      onTap: widget.onScanTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).scanPlant,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).scanDescription,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).startScanning,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.history_rounded,
        label: S.of(context).history,
        color: Colors.blue,
        onTap: widget.onHistoryTap,
      ),
      _QuickAction(
        icon: Icons.menu_book_rounded,
        label: S.of(context).diseases,
        color: Colors.orange,
        onTap: widget.onDiseasesTap,
      ),
      _QuickAction(
        icon: Icons.photo_library_rounded,
        label: S.of(context).gallery,
        color: Colors.purple,
        onTap: widget.onScanTap,
      ),
    ];

    return Row(
      children: actions
          .map((action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildActionCard(action),
                ),
              ))
          .toList(),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 28),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      _Feature(
        icon: Icons.auto_awesome,
        title: S.of(context).aiDetection,
        subtitle: S.of(context).aiDetectionDesc,
      ),
      _Feature(
        icon: Icons.translate,
        title: S.of(context).multilingual,
        subtitle: S.of(context).multilingualDesc,
      ),
      _Feature(
        icon: Icons.wifi_off_rounded,
        title: S.of(context).offlineReady,
        subtitle: S.of(context).offlineReadyDesc,
      ),
      _Feature(
        icon: Icons.medical_information_rounded,
        title: S.of(context).smartDiagnosis,
        subtitle: S.of(context).smartDiagnosisDesc,
      ),
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildFeatureTile(entry.value)
                    .animate()
                    .fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 300 + entry.key * 80))
                    .slideX(begin: 0.05),
              ))
          .toList(),
    );
  }

  Widget _buildFeatureTile(_Feature feature) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
