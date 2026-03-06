import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'providers/detection_provider.dart';
import 'providers/history_provider.dart';
import 'services/api_service.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app provider (loads saved preferences)
  final appProvider = AppProvider();
  await appProvider.initialize();

  // Create API service and configure URL from saved settings
  final apiService = ApiService();
  apiService.updateBaseUrl(appProvider.apiBaseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (_) => DetectionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(apiService)),
      ],
      child: const AgriScanApp(),
    ),
  );
}

class AgriScanApp extends StatelessWidget {
  const AgriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return MaterialApp(
      title: 'AgriScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: app.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}
