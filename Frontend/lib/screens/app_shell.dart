import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import 'diseases_screen.dart';
import 'settings_screen.dart';

/// Main app shell with bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _goToScan() => setState(() => _currentIndex = 1);
  void _goToResults() => setState(() => _currentIndex = 2);
  void _goToHistory() => setState(() => _currentIndex = 3);
  void _goToDiseases() => setState(() => _currentIndex = 3);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onScanTap: _goToScan,
        onHistoryTap: _goToHistory,
        onDiseasesTap: _goToDiseases,
      ),
      ScanScreen(onResultReady: _goToResults),
      const ResultsScreen(),
      const HistoryScreen(),
      const DiseasesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.clamp(0, 4),
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_rounded),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Diseases',
          ),
        ],
      ),
      // FAB for quick settings access
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.small(
              onPressed: () => _onTabTapped(5),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.settings_rounded, color: Colors.white),
            )
          : null,
    );
  }
}
