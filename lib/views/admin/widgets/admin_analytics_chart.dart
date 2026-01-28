import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';

class AdminAnalyticsChart extends StatelessWidget {
  AdminAnalyticsChart({super.key});

  final OrdersController orders = Get.find<OrdersController>();

  static const List<String> statuses = [
    "Placed",
    "Packed",
    "Shipped",
    "Delivered",
    "Cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final Map<String, int> counts = orders.adminStatusCount;
      final int total = counts.values.fold(0, (a, b) => a + b);

      // ---------- EMPTY STATE ----------
      if (total == 0) {
        return _emptyState(theme);
      }

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
              "Order Analytics",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // ---------- PIE CHART ----------
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      counts: counts,
                      statuses: statuses,
                      colorForStatus: (s) => _colorForStatus(s, cs),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ---------- LEGEND + RATIO ----------
                Expanded(
                  child: Column(
                    children: statuses.map((status) {
                      final count = counts[status] ?? 0;
                      final percent =
                          ((count / total) * 100).toStringAsFixed(1);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _colorForStatus(status, cs),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                status,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              "$percent%",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(ThemeData theme) {
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.pie_chart, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            "No analytics data",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS COLORS =================
  Color _colorForStatus(String status, ColorScheme cs) {
    switch (status) {
      case "Placed":
        return cs.primary;
      case "Packed":
        return Colors.orange;
      case "Shipped":
        return cs.secondary;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return cs.error;
      default:
        return cs.outline;
    }
  }
}

// ================= PIE PAINTER =================
class _PieChartPainter extends CustomPainter {
  final Map<String, int> counts;
  final List<String> statuses;
  final Color Function(String) colorForStatus;

  _PieChartPainter({
    required this.counts,
    required this.statuses,
    required this.colorForStatus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold(0, (a, b) => a + b);
    double startAngle = -pi / 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final status in statuses) {
      final value = counts[status] ?? 0;
      if (value == 0) continue;

      final sweepAngle = (value / total) * 2 * pi;
      paint.color = colorForStatus(status);

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}