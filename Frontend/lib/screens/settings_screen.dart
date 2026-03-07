import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
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
          content: Text(ok ? S.of(context).connectedSuccessfully : S.of(context).connectionFailed),
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
      appBar: AppBar(title: Text(S.of(context).settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          _buildSection(
            title: S.of(context).language,
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
            title: S.of(context).detection,
            icon: Icons.tune_rounded,
            child: Column(
              children: [
                ListTile(
                  title: Text(S.of(context).confidenceThreshold),
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
                  title: Text(S.of(context).saveToHistory),
                  subtitle: Text(S.of(context).saveToHistoryDesc),
                  value: app.saveHistory,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => app.setSaveHistory(val),
                ),
                SwitchListTile(
                  title: Text(S.of(context).voiceReading),
                  subtitle: Text(S.of(context).voiceReadingDesc),
                  value: app.voiceReadingEnabled,
                  activeTrackColor: AppColors.primary,
                  secondary: const Icon(Icons.volume_up_rounded),
                  onChanged: (val) => app.setVoiceReadingEnabled(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Server Configuration
          _buildSection(
            title: S.of(context).server,
            icon: Icons.dns_rounded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: S.of(context).apiBaseUrl,
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
                          label: Text(S.of(context).test),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            app.setApiBaseUrl(_urlController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(S.of(context).urlSaved)),
                            );
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: Text(S.of(context).save),
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
            title: S.of(context).appearance,
            icon: Icons.palette_rounded,
            child: SwitchListTile(
              title: Text(S.of(context).darkMode),
              subtitle: Text(S.of(context).darkModeDesc),
              value: app.darkMode,
              activeTrackColor: AppColors.primary,
              onChanged: (val) => app.setDarkMode(val),
            ),
          ),
          const SizedBox(height: 16),

          // About
          _buildSection(
            title: S.of(context).about,
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
                    S.of(context).version(AppConfig.appVersion),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).aboutDescription,
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
