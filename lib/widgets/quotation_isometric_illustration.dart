import 'package:flutter/material.dart';

class QuotationIsometricIllustration extends StatelessWidget {
  final double scale;

  const QuotationIsometricIllustration({
    super.key,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        height: 380,
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient Glow behind sheet
            Positioned(
              bottom: 20,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Main Angled Quotation Card
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateZ(-0.08)
                ..rotateY(0.04)
                ..rotateX(-0.02),
              alignment: Alignment.center,
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blue Header Banner Pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'QUOTATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Skeleton Placeholder Lines
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('QTY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                          Text('RATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                          Text('AMOUNT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rows
                    _buildRow('2', '₹1,200', '₹2,400'),
                    const SizedBox(height: 4),
                    _buildRow('1', '₹850', '₹850'),
                    const SizedBox(height: 4),
                    _buildRow('3', '₹650', '₹1,950'),
                    const SizedBox(height: 8),

                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 6),

                    // Summary
                    _buildSummaryLine('Subtotal', '₹5,200'),
                    const SizedBox(height: 2),
                    _buildSummaryLine('GST (18%)', '₹936'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                        ),
                        Text(
                          '₹6,136',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Signature & Stamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Signature line
                        CustomPaint(
                          size: const Size(55, 18),
                          painter: _SignaturePainter(),
                        ),

                        // Verified stamp circle badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.check_rounded, size: 14, color: Color(0xFF6366F1)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Floating Badge 1: User Avatar (Left)
            Positioned(
              left: 10,
              top: 130,
              child: _buildCircleBadge(
                icon: Icons.person_rounded,
                color: const Color(0xFF6366F1),
                iconColor: Colors.white,
                size: 40,
              ),
            ),

            // Floating Badge 2: Send / Airplane (Bottom Left)
            Positioned(
              left: 28,
              bottom: 60,
              child: _buildCircleBadge(
                icon: Icons.send_rounded,
                color: const Color(0xFF818CF8),
                iconColor: Colors.white,
                size: 36,
              ),
            ),

            // Floating Badge 3: Bar Chart (Right)
            Positioned(
              right: 18,
              top: 135,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1), size: 22),
              ),
            ),

            // Desk Plant Illustration at Bottom Left
            Positioned(
              left: 20,
              bottom: 0,
              child: _buildPottedPlant(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String qty, String rate, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(qty, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          Text(rate, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          Text(amount, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 7.5, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _buildCircleBadge({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  Widget _buildPottedPlant() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Plant Leaves
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Center Leaf
            Container(
              width: 14,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
            // Left Leaf
            Transform.translate(
              offset: const Offset(-8, -2),
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 12,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Right Leaf
            Transform.translate(
              offset: const Offset(8, -2),
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 12,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Pot
        Container(
          width: 24,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.4, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.9, size.width * 0.7, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.2, size.width * 0.95, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
