import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  String? _errorMessage;

  // ── Hardcoded credentials ──
  static const String _validEmail = 'admin@agriscan.com';
  static const String _validPassword = 'agriscan2026';

  // Design colors
  static const Color _sageGreen = Color(0xFF899B91);
  static const Color _fieldBg = Color(0xFFD5D5D5);
  static const Color _fieldFocusBorder = Color(0xFF4BA3D4);
  static const Color _darkText = Color(0xFF2D3A35);
  static const Color _buttonBg = Color(0xFFE0DDD8);
  static const Color _socialBg = Color(0xFFE8E5E0);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = S.of(context).fillAllFields);
      return;
    }

    if (email == _validEmail && password == _validPassword) {
      setState(() => _errorMessage = null);
      Navigator.pushReplacementNamed(context, '/login-success');
    } else {
      setState(() => _errorMessage = S.of(context).invalidCredentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _sageGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // ── Leaf icon ──
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _LeafEmblemPainter(),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── E-mail label ──
              Text(
                S.of(context).email,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),

              // ── E-mail field ──
              Focus(
                onFocusChange: (_) => setState(() {}),
                child: TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 14, color: _darkText),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldBg.withValues(alpha: 0.55),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(
                          color: _fieldFocusBorder, width: 2.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Password label ──
              Text(
                S.of(context).password,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),

              // ── Password field ──
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                style: GoogleFonts.poppins(fontSize: 14, color: _darkText),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldBg.withValues(alpha: 0.55),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide:
                        const BorderSide(color: _fieldFocusBorder, width: 2.5),
                  ),
                ),
              ),

              // ── Error message ──
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFFFCDD2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ── LOGIN button ──
              Center(
                child: GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: 150,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _buttonBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'LOGIN',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _darkText,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Forgot Password ──
              Center(
                child: Text(
                  'Forgot Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── "or" divider ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Continue with Google (non-functional) ──
              _SocialButton(
                iconWidget: Text(
                  'G',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF4285F4),
                          Color(0xFFDB4437),
                          Color(0xFFF4B400),
                          Color(0xFF0F9D58),
                        ],
                      ).createShader(
                          const Rect.fromLTWH(0, 0, 24, 24)),
                  ),
                ),
                label: 'Continue with Google',
              ),

              const SizedBox(height: 14),

              // ── Sign up with Facebook (non-functional) ──
              _SocialButton(
                iconWidget: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1877F2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'f',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                label: 'Sign up with Facebook',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Leaf emblem drawn inside the circle
class _LeafEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final leafH = size.height * 0.36;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Leaf outline
    final leafPath = Path()
      ..moveTo(cx, cy - leafH)
      ..quadraticBezierTo(cx + leafH * 0.85, cy - leafH * 0.2, cx, cy + leafH)
      ..quadraticBezierTo(cx - leafH * 0.85, cy - leafH * 0.2, cx, cy - leafH);
    canvas.drawPath(leafPath, paint);

    // Center vein
    canvas.drawLine(
      Offset(cx, cy - leafH * 0.7),
      Offset(cx, cy + leafH * 0.7),
      paint..strokeWidth = 1.4,
    );

    // Side veins
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i <= 4; i++) {
      final t = i * 0.19;
      final vy = cy - leafH + leafH * 2 * t;
      final spread = leafH * 0.38 * (1 - ((t - 0.45).abs() * 1.6).clamp(0, 1));
      canvas.drawLine(Offset(cx, vy), Offset(cx + spread, vy - leafH * 0.08), veinPaint);
      canvas.drawLine(Offset(cx, vy), Offset(cx - spread, vy - leafH * 0.08), veinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Social login button (non-functional placeholder)
class _SocialButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;

  const _SocialButton({required this.iconWidget, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E5E0),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(width: 32, child: Center(child: iconWidget)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3A35),
            ),
          ),
        ],
      ),
    );
  }
}
