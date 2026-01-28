import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../controllers/orders_controller.dart';

class AdminOrderDetailView extends StatelessWidget {
  final OrderModel order;

  AdminOrderDetailView({super.key, required this.order});

  final orders = Get.find<OrdersController>();

  static const steps = ["Placed", "Packed", "Shipped", "Delivered"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isCancelled = order.status == "Cancelled";
    final canCancel = order.status == "Placed" || order.status == "Packed";
    final currentStep = isCancelled ? -1 : steps.indexOf(order.status);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER SUMMARY =================
            _glassHeader(),

            const SizedBox(height: 24),

            // ================= STATUS TIMELINE =================
            _section(
              title: "Order Progress",
              child: Column(
                children: [
                  ...List.generate(steps.length, (index) {
                    final completed =
                        !isCancelled && index <= currentStep;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                            child: Icon(
                              completed
                                  ? Icons.check_rounded
                                  : Icons.circle_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            steps[index],
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (isCancelled)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Order Cancelled",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= UPDATE STATUS =================
            if (!isCancelled)
              _section(
                title: "Update Order Status",
                child: DropdownButtonFormField<String>(
                  value: order.status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: steps
                      .where((s) =>
                          steps.indexOf(s) >=
                          steps.indexOf(order.status))
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      orders.updateStatus(order.id, v);
                    }
                  },
                ),
              ),

            const SizedBox(height: 20),

            // ================= CANCEL ORDER =================
            if (canCancel && !isCancelled)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
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
                            onPressed: () {
                              orders.cancelOrder(order.id);
                              Get.back();
                              Get.back();
                            },
                            child: const Text("Yes, Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                  label: const Text(
                    "Cancel Order",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ================= ITEMS =================
            _section(
              title: "Ordered Items",
              child: Column(
                children: order.items.map((i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            i.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "₹${i.price}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ================= DELIVERY INFO =================
            _section(
              title: "Delivery Information",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📍 Address: ${order.address}"),
                  const SizedBox(height: 6),
                  Text("📞 Mobile: ${order.mobile}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _glassHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Total Amount: ₹${order.total}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Payment Method: ${order.paymentMethod}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= SECTION =================
  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}