import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  static const Color _sageGreen = Color(0xFF899B91);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                S.of(context).loginSuccessful,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );

      // Navigate to home after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _sageGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leaf icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: _LeafPainter(),
              ),
            ),
            const SizedBox(height: 28),
            // Hello there! Welcome Back!
            Text(
              S.of(context).helloWelcomeBack,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
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
      final spread =
          leafH * 0.38 * (1 - ((t - 0.45).abs() * 1.6).clamp(0.0, 1.0));
      canvas.drawLine(
          Offset(cx, vy), Offset(cx + spread, vy - leafH * 0.08), veinPaint);
      canvas.drawLine(
          Offset(cx, vy), Offset(cx - spread, vy - leafH * 0.08), veinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
