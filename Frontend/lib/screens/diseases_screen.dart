import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/disease.dart';
import '../services/api_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

/// Screen showing disease encyclopedia / list of all detectable diseases
class DiseasesScreen extends StatefulWidget {
  const DiseasesScreen({super.key});

  @override
  State<DiseasesScreen> createState() => _DiseasesScreenState();
}

class _DiseasesScreenState extends State<DiseasesScreen> {
  List<String> _diseases = [];
  List<String> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseases() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final app = context.read<AppProvider>();
    api.updateBaseUrl(app.apiBaseUrl);

    final diseases = await api.getAllDiseases();
    setState(() {
      _diseases = diseases;
      _filtered = diseases;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _diseases;
      } else {
        _filtered = _diseases
            .where((d) => d.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseases'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search diseases...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Disease count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} diseases',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Diseases Found',
                        subtitle: 'Try a different search term',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final disease = _filtered[index];
                          final isHealthy = disease.toLowerCase().contains('healthy') ||
                              (!disease.toLowerCase().contains('blight') &&
                                  !disease.toLowerCase().contains('spot') &&
                                  !disease.toLowerCase().contains('rot') &&
                                  !disease.toLowerCase().contains('rust') &&
                                  !disease.toLowerCase().contains('mold') &&
                                  !disease.toLowerCase().contains('virus') &&
                                  !disease.toLowerCase().contains('mites') &&
                                  !disease.toLowerCase().contains('mildew') &&
                                  !disease.toLowerCase().contains('bacterial'));

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.divider),
                              ),
                              tileColor: AppColors.surface,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isHealthy
                                      ? AppColors.healthy.withValues(alpha: 0.1)
                                      : AppColors.highSeverity.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isHealthy
                                      ? Icons.eco_rounded
                                      : Icons.bug_report_rounded,
                                  color: isHealthy
                                      ? AppColors.healthy
                                      : AppColors.highSeverity,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                disease,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                              ),
                              onTap: () => _showDiseaseDetail(context, disease),
                            ),
                          ).animate().fadeIn(
                                duration: 300.ms,
                                delay: Duration(
                                    milliseconds: (index * 40).clamp(0, 400)),
                              );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showDiseaseDetail(BuildContext context, String diseaseName) {
    final app = context.read<AppProvider>();
    final api = ApiService();
    api.updateBaseUrl(app.apiBaseUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return _DiseaseDetailSheet(
            diseaseName: diseaseName,
            api: api,
            language: app.language,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _DiseaseDetailSheet extends StatefulWidget {
  final String diseaseName;
  final ApiService api;
  final String language;
  final ScrollController scrollController;

  const _DiseaseDetailSheet({
    required this.diseaseName,
    required this.api,
    required this.language,
    required this.scrollController,
  });

  @override
  State<_DiseaseDetailSheet> createState() => _DiseaseDetailSheetState();
}

class _DiseaseDetailSheetState extends State<_DiseaseDetailSheet> {
  Disease? _disease;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiagnosis();
  }

  Future<void> _loadDiagnosis() async {
    final result = await widget.api.getDiagnosis(
      diseaseName: widget.diseaseName,
      language: widget.language,
    );

    setState(() {
      _loading = false;
      if (result.success && result.disease != null) {
        _disease = result.disease;
      } else {
        _error = result.error ?? 'Failed to load diagnosis';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  controller: widget.scrollController,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _disease!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_disease!.scientificName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _disease!.scientificName!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SeverityBadge(severity: _disease!.severity),
                    const SizedBox(height: 16),

                    // Description
                    if (_disease!.description != null) ...[
                      Text(
                        _disease!.description!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Symptoms
                    if (_disease!.symptoms.isNotEmpty) ...[
                      const SectionHeader(
                        title: 'Symptoms',
                        icon: Icons.sick_rounded,
                      ),
                      ..._disease!.symptoms.map((s) => _bullet(s)),
                      const SizedBox(height: 16),
                    ],

                    // Treatment
                    if (_disease!.treatment.all.isNotEmpty) ...[
                      const SectionHeader(
                        title: 'Treatment',
                        icon: Icons.healing_rounded,
                      ),
                      ..._disease!.treatment.all.map((t) => _bullet(t)),
                      const SizedBox(height: 16),
                    ],

                    // Prevention
                    if (_disease!.prevention.isNotEmpty) ...[
                      const SectionHeader(
                        title: 'Prevention',
                        icon: Icons.shield_rounded,
                      ),
                      ..._disease!.prevention.map((p) => _bullet(p)),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: AppColors.primary)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
