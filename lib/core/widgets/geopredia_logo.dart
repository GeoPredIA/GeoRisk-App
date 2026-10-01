import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GeoPredIALogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const GeoPredIALogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.primaryDark;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Geo',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: size * 0.48,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Pre',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: size * 0.48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.riskLow,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'IA',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: size * 0.48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.riskMedium,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'SISTEMA INTELIGENTE DE RIESGOS',
                style: TextStyle(
                  fontSize: size * 0.17,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final hexPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0E3B2E), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.26),
    );
    canvas.drawRRect(rrect, hexPaint);

    final peakPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.72, h * 0.68)
      ..lineTo(w * 0.28, h * 0.68)
      ..close();
    canvas.drawPath(path, peakPaint);

    final leftPeakPaint = Paint()..color = const Color(0xFF81C784);
    final leftPath = Path()
      ..moveTo(w * 0.30, h * 0.40)
      ..lineTo(w * 0.48, h * 0.72)
      ..lineTo(w * 0.16, h * 0.72)
      ..close();
    canvas.drawPath(leftPath, leftPeakPaint);

    final rightPeakPaint = Paint()..color = const Color(0xFFFFB74D);
    final rightPath = Path()
      ..moveTo(w * 0.70, h * 0.44)
      ..lineTo(w * 0.84, h * 0.72)
      ..lineTo(w * 0.54, h * 0.72)
      ..close();
    canvas.drawPath(rightPath, rightPeakPaint);

    final sensorDot = Paint()..color = const Color(0xFF00E676);
    canvas.drawCircle(Offset(w * 0.5, h * 0.17), w * 0.055, sensorDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
