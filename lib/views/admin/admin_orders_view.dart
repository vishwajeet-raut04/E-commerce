import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/orders_controller.dart';
import 'admin_order_detail_view.dart';

class AdminOrdersView extends StatelessWidget {
  AdminOrdersView({super.key});

  final OrdersController orders = Get.find<OrdersController>();

  // ================= STATUS HELPERS (UNCHANGED) =================

  Color _statusColor(String status, ColorScheme cs) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return cs.error;
      case "Shipped":
        return Colors.purple;
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Orders Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        final list = orders.orders;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No Orders Found",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Orders will appear here once placed",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, index) {
              final o = list[index];
              final color = _statusColor(o.status, cs);

              return GestureDetector(
                onTap: () {
                  Get.to(() => AdminOrderDetailView(order: o));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF0F172A),
                              const Color(0xFF020617),
                            ]
                          : [
                              Colors.white,
                              const Color(0xFFF8FAFC),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,
                        color: Colors.black.withOpacity(
                          isDark ? 0.45 : 0.08,
                        ),
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ================= STATUS BAR =================
                      Container(
                        width: 8,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.7),
                              color,
                            ],
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(26),
                          ),
                        ),
                      ),

                      // ================= CONTENT =================
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ---------- TOP ROW ----------
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withOpacity(0.15),
                                    ),
                                    child: Icon(
                                      _statusIcon(o.status),
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      "₹${o.total.toStringAsFixed(2)}",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ---------- STATUS CHIP ----------
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
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

                              const SizedBox(height: 14),

                              // ---------- META INFO ----------
                              Row(
                                children: [
                                  _metaItem(
                                    Icons.shopping_cart_outlined,
                                    "Items",
                                    o.items.length.toString(),
                                    theme,
                                  ),
                                  const SizedBox(width: 16),
                                  _metaItem(
                                    Icons.payment_rounded,
                                    "Payment",
                                    o.paymentMethod,
                                    theme,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ---------- USER ----------
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      o.userEmail,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // ---------- ORDER ID ----------
                              Text(
                                "Order ID • ${o.id.substring(0, 8)}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ================= MINI META WIDGET =================

  Widget _metaItem(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}