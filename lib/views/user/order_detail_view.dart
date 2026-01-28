import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../controllers/orders_controller.dart';

class OrderDetailView extends StatelessWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  static const List<String> steps = [
    "Placed",
    "Packed",
    "Shipped",
    "Delivered",
  ];

  String getEstimatedDelivery() {
    switch (order.status) {
      case "Placed":
        return "Delivery in 5–7 days";
      case "Packed":
        return "Delivery in 3–5 days";
      case "Shipped":
        return "Delivery in 1–2 days";
      case "Delivered":
        return "Delivered";
      case "Cancelled":
        return "Order Cancelled";
      default:
        return "Processing";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool isCancelled = order.status == "Cancelled";
    final int currentStep = isCancelled ? -1 : steps.indexOf(order.status);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Order Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STATUS HEADER =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCancelled
                    ? cs.errorContainer
                    : cs.primaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Status",
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getEstimatedDelivery(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= TIMELINE =================
            Text(
              "Tracking",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...List.generate(steps.length, (index) {
              final completed = !isCancelled && index <= currentStep;

              final Color activeColor = completed ? Colors.green : cs.outline;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: activeColor,
                        child: Icon(
                          completed ? Icons.check : Icons.circle,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (index != steps.length - 1)
                        Container(
                          width: 2,
                          height: 36,
                          color: activeColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      steps[index],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            completed ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              );
            }),

            if (isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "This order was cancelled.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // ================= INVOICE =================
            Text(
              "Order Invoice",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "₹${item.price}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${order.total}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= DELIVERY INFO =================
            Text(
              "Delivery Information",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Address: ${order.address}"),
            Text("Mobile: ${order.mobile}"),
            Text("Payment: ${order.paymentMethod}"),

            const SizedBox(height: 32),

            // ================= USER CANCEL =================
            if (!isCancelled &&
                (order.status == "Placed" || order.status == "Packed"))
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _confirmCancel(context),
                  child: const Text(
                    "Cancel Order",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= CONFIRM DIALOG =================
  void _confirmCancel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text(
          "Are you sure you want to cancel this order?",
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () {
              Get.find<OrdersController>().cancelOrder(order.id);
              Get.back(); // dialog
              Get.back(); // detail screen
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }
}
