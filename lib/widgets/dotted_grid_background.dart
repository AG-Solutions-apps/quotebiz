import 'package:flutter/material.dart';

class DottedGridBackground extends StatelessWidget {
  final Widget child;

  const DottedGridBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Clean Background
        Container(
          color: const Color(0xFFF8FAFC),
        ),

        // Ambient Dark Blue & Cyan Gradient Glow Blobs
        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2563EB).withValues(alpha: 0.12),
                  const Color(0xFF06B6D4).withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -120,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.08),
                  const Color(0xFF2563EB).withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Custom Dotted Grid Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _DottedGridPainter(),
          ),
        ),

        // Main Content Child
        child,
      ],
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    const double spacing = 24.0;
    const double radius = 1.4;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
