import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';

class RevenueTrendChart extends StatelessWidget {
  RevenueTrendChart({super.key});

  final OrdersController orders = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      // ✅ ADMIN DATA (GLOBAL)
      final List<double> data = orders.adminRevenueTrend;

      // ---------- NOT ENOUGH DATA ----------
      if (data.length < 2) {
        return Container(
          height: 180,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
              ),
            ],
          ),
          child: Text(
            "Not enough data for trend",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        );
      }

      final double maxValue = data.reduce((a, b) => a > b ? a : b);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Revenue Trend",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  data: data,
                  maxValue: maxValue,
                  scheme: cs,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ===================================================
// ================= CUSTOM PAINTER ==================
// ===================================================

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final ColorScheme scheme;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.scheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = scheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double y = size.height - (data[i] / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw data point
      canvas.drawCircle(
        Offset(x, y),
        3.5,
        paintDot,
      );
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
