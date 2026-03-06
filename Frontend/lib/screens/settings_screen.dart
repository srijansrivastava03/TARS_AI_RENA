import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _testingConnection = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _urlController.text = app.apiBaseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() => _testingConnection = true);
    final api = ApiService();
    api.updateBaseUrl(_urlController.text.trim());
    final ok = await api.healthCheck();
    setState(() => _testingConnection = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '✅ Connected successfully!' : '❌ Connection failed'),
          backgroundColor: ok ? AppColors.healthy : AppColors.error,
        ),
      );
      if (ok) {
        context.read<AppProvider>().setApiBaseUrl(_urlController.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          _buildSection(
            title: 'Language',
            icon: Icons.translate_rounded,
            child: Column(
              children: AppConfig.supportedLanguages.entries
                  .map((entry) => ListTile(
                        title: Text(entry.value),
                        subtitle: Text(entry.key.toUpperCase()),
                        leading: Icon(
                          entry.key == app.language
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: entry.key == app.language
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        onTap: () => app.setLanguage(entry.key),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Detection Settings
          _buildSection(
            title: 'Detection',
            icon: Icons.tune_rounded,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Confidence Threshold'),
                  subtitle: Text('${(app.confidenceThreshold * 100).round()}%'),
                  trailing: SizedBox(
                    width: 180,
                    child: Slider(
                      value: app.confidenceThreshold,
                      min: 0.1,
                      max: 0.95,
                      divisions: 17,
                      activeColor: AppColors.primary,
                      label: '${(app.confidenceThreshold * 100).round()}%',
                      onChanged: (val) => app.setConfidenceThreshold(val),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Save to History'),
                  subtitle: const Text('Automatically save scan results'),
                  value: app.saveHistory,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => app.setSaveHistory(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Server Configuration
          _buildSection(
            title: 'Server',
            icon: Icons.dns_rounded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://localhost:5001/api',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _testingConnection
                              ? null
                              : _testConnection,
                          icon: _testingConnection
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.wifi_find_rounded),
                          label: const Text('Test'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            app.setApiBaseUrl(_urlController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL saved')),
                            );
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Appearance
          _buildSection(
            title: 'Appearance',
            icon: Icons.palette_rounded,
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch to dark theme'),
              value: app.darkMode,
              activeTrackColor: AppColors.primary,
              onChanged: (val) => app.setDarkMode(val),
            ),
          ),
          const SizedBox(height: 16),

          // About
          _buildSection(
            title: 'About',
            icon: Icons.info_outline_rounded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConfig.appVersion}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI-powered plant disease detection with multilingual support. '
                    'Built with Flutter + Flask + YOLO + RAG.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
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
          ),
          child,
        ],
      ),
    );
  }
}
