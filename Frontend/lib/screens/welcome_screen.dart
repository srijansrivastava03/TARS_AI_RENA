import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Design colors matched from reference
  static const Color _sageGreen = Color(0xFF899B91);
  static const Color _darkTeal = Color(0xFF1A3C34);
  static const Color _creamWhite = Color(0xFFF8F6F1);

  @override
  Widget build(BuildContext context) {
    // Make status bar blend with the cream top
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Column(
        children: [
          // ─── Top cream section ─────────────────────────────
          Expanded(
            flex: 42,
            child: Container(
              color: _creamWhite,
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Language toggle button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _LanguageToggleChip(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // "AGRI-SCAN" title
                    Text(
                      S.of(context).appName.toUpperCase(),
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _darkTeal,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Small divider line
                    Container(
                      width: 40,
                      height: 2,
                      color: _darkTeal.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 20),
                    // Plant in pot image
                    Expanded(
                      child: Image.asset(
                        'assets/images/plant_pot.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Bottom sage green section ─────────────────────
          Expanded(
            flex: 58,
            child: Container(
              color: _sageGreen,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Quote
                  Text(
                    S.of(context).expertCare,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: _darkTeal,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Subtitle
                  Text(
                    S.of(context).welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _WelcomeButton(
                          label: S.of(context).register,
                          onTap: () => _navigateForward(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _WelcomeButton(
                          label: S.of(context).signIn,
                          onTap: () => _navigateForward(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateForward(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

/// Language toggle chip — cycles through supported languages
class _LanguageToggleChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final languages = AppConfig.supportedLanguages;
    final keys = languages.keys.toList();
    final currentIndex = keys.indexOf(app.language);
    final currentLabel = languages[app.language] ?? 'English';

    return GestureDetector(
      onTap: () {
        final nextIndex = (currentIndex + 1) % keys.length;
        app.setLanguage(keys[nextIndex]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3C34).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1A3C34).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded,
                size: 16, color: Color(0xFF1A3C34)),
            const SizedBox(width: 6),
            Text(
              currentLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3C34),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.swap_horiz_rounded,
                size: 14, color: Color(0xFF1A3C34)),
          ],
        ),
      ),
    );
  }
}

/// Outlined button matching the reference design
class _WelcomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WelcomeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF2D3A35),
            width: 1.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3A35),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
