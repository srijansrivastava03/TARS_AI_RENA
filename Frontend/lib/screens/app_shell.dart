import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import 'diseases_screen.dart';
import 'settings_screen.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';

/// Main app shell with bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Nav indices: 0=Home, 1=Notifications, 2=Scan, 3=Analytics, 4=Account(Settings)
  int _currentIndex = 0;

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  bool _wasConnected = true;
  bool _initialCheckDone = false;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);

    // Show welcome snackbar (simulates successful login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSnackBar(
        icon: Icons.check_circle_rounded,
        message: 'Welcome back! You\'re logged in.',
        color: const Color(0xFF4CAF50),
      );
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected =
        results.any((r) => r != ConnectivityResult.none);

    // Skip the very first event to avoid a false "back online" on launch
    if (!_initialCheckDone) {
      _wasConnected = isConnected;
      _initialCheckDone = true;
      return;
    }

    if (isConnected && !_wasConnected) {
      _showSnackBar(
        icon: Icons.wifi_rounded,
        message: 'You\'re back online!',
        color: const Color(0xFF4CAF50),
      );
    } else if (!isConnected && _wasConnected) {
      _showSnackBar(
        icon: Icons.wifi_off_rounded,
        message: 'You\'re offline. Check your connection.',
        color: const Color(0xFFF44336),
        duration: const Duration(seconds: 5),
      );
    }
    _wasConnected = isConnected;
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
          duration: duration,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _goToScan() => setState(() => _currentIndex = 2);
  void _goToResults() => _navigateTo(const ResultsScreen());
  void _goToHistory() => _navigateTo(const HistoryScreen());
  void _goToDiseases() => _navigateTo(const DiseasesScreen());

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onScanTap: _goToScan,
        onHistoryTap: _goToHistory,
        onDiseasesTap: _goToDiseases,
      ),
      const NotificationsScreen(),
      ScanScreen(onResultReady: () => _navigateTo(const ResultsScreen())),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          // Hide nav bar on Scan page (index 2)
          if (_currentIndex != 2)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 10,
              child: _FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Dark bar
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3C34),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // Spacer for scan button
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Analytics',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Account',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
          // Floating scan button
          Positioned(
            top: -6,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE85D4A), Color(0xFFD94437)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.white54;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
