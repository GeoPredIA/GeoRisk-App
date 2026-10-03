import 'dart:math';
import 'package:flutter/material.dart';

class TopographicBackground extends StatelessWidget {
  final Widget? child;

  const TopographicBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFBF9),
      child: CustomPaint(
        painter: const _TopographicContourPainter(),
        child: child,
      ),
    );
  }
}

class _TopographicContourPainter extends CustomPainter {
  const _TopographicContourPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF0E3B2E).withValues(alpha: 0.035);

    final subtleGridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF64748B).withValues(alpha: 0.02);

    const gridSpacing = 80.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), subtleGridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), subtleGridPaint);
    }

    final centers = [
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.85),
    ];

    for (final center in centers) {
      for (int i = 1; i <= 6; i++) {
        final radiusX = i * 45.0;
        final radiusY = i * 32.0;
        final path = Path();

        const segments = 36;
        for (int j = 0; j <= segments; j++) {
          final theta = (j / segments) * 2 * pi;
          final distortion = 1.0 + (0.08 * sin(theta * 3)) + (0.05 * cos(theta * 2));
          final x = center.dx + (radiusX * distortion * cos(theta));
          final y = center.dy + (radiusY * distortion * sin(theta));

          if (j == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, paint);
      }
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF0E3B2E).withValues(alpha: 0.025);

    for (double offsetY = size.height * 0.1; offsetY < size.height; offsetY += 180.0) {
      final path = Path()..moveTo(0, offsetY);
      for (double x = 0; x <= size.width; x += 30) {
        final y = offsetY + sin(x * 0.015 + offsetY) * 16.0;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
