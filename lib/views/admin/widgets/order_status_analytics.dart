import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';

class OrderStatusAnalytics extends StatelessWidget {
  OrderStatusAnalytics({super.key});

  final OrdersController orders = Get.find<OrdersController>();

  // ================= STATUS COLORS =================
  Color _statusColor(String status, ColorScheme cs) {
    switch (status) {
      case "Placed":
        return cs.primary;
      case "Packed":
        return Colors.orange;
      case "Shipped":
        return Colors.deepPurpleAccent;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return cs.error;
      default:
        return cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      // ✅ ADMIN DATA (GLOBAL)
      final Map<String, int> map = orders.adminStatusCount;
      final int total = orders.adminTotalOrders;

      // ---------- EMPTY STATE ----------
      if (total == 0 || map.values.every((v) => v == 0)) {
        return Container(
          padding: const EdgeInsets.all(20),
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
          child: Center(
            child: Text(
              "No order status data",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        );
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
              "Order Status Breakdown",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...map.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();

              final color = _statusColor(entry.key, cs);
              final double progress = entry.value / total;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- LABEL ROW --------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // -------- PROGRESS BAR --------
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor:
                            cs.surfaceVariant.withOpacity(isDark ? 0.4 : 1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
