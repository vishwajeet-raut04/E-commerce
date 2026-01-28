import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/orders_controller.dart';
import '../../controllers/cart_controller.dart';
import 'order_detail_view.dart';

class UserOrdersView extends StatelessWidget {
  UserOrdersView({super.key});

  final OrdersController orders = Get.find<OrdersController>();
  final CartController cart = Get.find<CartController>();

  static const steps = ["Placed", "Packed", "Shipped", "Delivered"];

  // ================= STATUS HELPERS =================

  Color _statusColor(String status, ColorScheme cs) {
    switch (status) {
      case "Delivered":
        return Colors.green.shade600;
      case "Cancelled":
        return cs.error;
      case "Shipped":
        return Colors.deepPurple;
      case "Packed":
        return Colors.orange;
      case "Placed":
        return cs.primary;
      default:
        return cs.outline;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Delivered":
        return Icons.check_circle_rounded;
      case "Cancelled":
        return Icons.cancel_rounded;
      case "Shipped":
        return Icons.local_shipping_rounded;
      case "Packed":
        return Icons.inventory_2_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed("/user-root"),
        ),
      ),
      body: Obx(() {
        final list = orders.filteredOrders;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 72, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                Text("No orders yet", style: theme.textTheme.titleMedium),
                Text(
                  "Your orders will appear here",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: list.length,
          itemBuilder: (_, index) {
            final o = list[index];
            final color = _statusColor(o.status, cs);
            final currentStep = steps.indexOf(o.status);

            return GestureDetector(
              onTap: () => Get.to(() => OrderDetailView(order: o)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(
                        theme.brightness == Brightness.dark ? 0.4 : 0.08,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= HEADER =================
                      Row(
                        children: [
                          Icon(_statusIcon(o.status), color: color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "₹${o.total.toStringAsFixed(2)}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= STATUS CHIP =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          o.status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= MINI TIMELINE =================
                      Row(
                        children: List.generate(steps.length, (i) {
                          final completed =
                              o.status != "Cancelled" && i <= currentStep;

                          return Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor:
                                      completed ? color : cs.outline,
                                ),
                                if (i != steps.length - 1)
                                  Container(
                                    height: 2,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    color: completed ? color : cs.outline,
                                  ),
                                Text(
                                  steps[i],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color:
                                        completed ? color : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // ================= META =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items: ${o.items.length}",
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            o.paymentMethod,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= BUY AGAIN =================
                      if (o.status == "Delivered" || o.status == "Cancelled")
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Buy Again"),
                            onPressed: () {
                              for (final item in o.items) {
                                cart.add(item);
                              }
                              Get.snackbar(
                                "Added to Cart",
                                "${o.items.length} items added",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.toNamed("/cart");
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
