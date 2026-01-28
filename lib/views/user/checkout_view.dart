import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/order_model.dart';
import 'order_success_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final CartController cart = Get.find<CartController>();
  final OrdersController orders = Get.find<OrdersController>();
  final CheckoutController checkout = Get.find<CheckoutController>();
  final SessionController session = Get.find<SessionController>();

  bool placing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Checkout"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ================= CONTENT =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section("Delivery Details"),

                _card(
                  child: TextField(
                    onChanged: (v) => checkout.address.value = v,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Delivery Address",
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  child: TextField(
                    onChanged: (v) => checkout.mobile.value = v,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= DELIVERY =================
                _section("Delivery Speed"),

                _deliveryOption(
                  title: "Standard",
                  subtitle: "2–4 business days · Free",
                  value: "Standard (2–4 days)",
                ),
                _deliveryOption(
                  title: "Express",
                  subtitle: "1–2 business days · ₹99",
                  value: "Express (1–2 days)",
                ),

                const SizedBox(height: 24),

                // ================= PAYMENT =================
                _section("Payment Method"),

                _paymentTile(
                  icon: Icons.payments_outlined,
                  label: "Cash on Delivery",
                  value: "Cash on Delivery",
                ),
                _paymentTile(
                  icon: Icons.qr_code_2_outlined,
                  label: "UPI",
                  value: "UPI",
                ),
                _paymentTile(
                  icon: Icons.credit_card_outlined,
                  label: "Card",
                  value: "Card",
                ),

                const SizedBox(height: 24),

                // ================= SUMMARY =================
                _section("Order Summary"),

                Obx(
                  () => _card(
                    child: Column(
                      children: [
                        _row(
                          "Items (${cart.cartItems.length})",
                          "₹${cart.total.toStringAsFixed(2)}",
                        ),
                        _row(
                          "Delivery",
                          checkout.deliveryEta.value,
                        ),
                        if (checkout.deliveryFee > 0)
                          _row(
                            "Express Fee",
                            "+₹${checkout.deliveryFee.toStringAsFixed(2)}",
                            highlight: true,
                          ),
                        const Divider(height: 24),
                        _row(
                          "Total",
                          "₹${checkout.finalTotal.toStringAsFixed(2)}",
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Secure checkout",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= FOOTER =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Obx(() {
                final valid = checkout.address.value.isNotEmpty &&
                    checkout.mobile.value.length >= 10 &&
                    !placing;

                return ElevatedButton(
                  onPressed: valid ? _placeOrder : null,
                  child: placing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Place Order",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ================= ACTION ============================
  // =====================================================

  Future<void> _placeOrder() async {
    if (session.currentUser.value == null) return;

    setState(() => placing = true);

    final user = session.currentUser.value!;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final order = OrderModel(
      id: orderId,
      userEmail: user.email,
      items: List.from(cart.cartItems),
      total: checkout.finalTotal, // ✅ EXPRESS INCLUDED
      address: checkout.address.value,
      mobile: checkout.mobile.value,
      paymentMethod: checkout.payment.value,
      deliveryType: checkout.isExpress ? "Express" : "Standard",
      createdAt: DateTime.now(),
    );

    orders.placeOrder(order);
    cart.clearCart();
    checkout.resetForm();

    setState(() => placing = false);

    Get.offAll(
      () => OrderSuccessView(
        orderId: orderId,
        total: order.total,
        itemCount: order.items.length,
        payment: order.paymentMethod,
        address: order.address,
        deliveryEta: checkout.deliveryEta.value, // ✅ PASSED
      ),
    );
  }

  // =====================================================
  // ================= UI HELPERS ========================
  // =====================================================

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool highlight = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: highlight ? Colors.orange : null,
                fontSize: bold ? 18 : 14,
              ),
            ),
          ],
        ),
      );

  Widget _deliveryOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Obx(
      () => ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: Theme.of(Get.context!).cardColor,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Radio<String>(
          value: value,
          groupValue: checkout.deliveryEta.value,
          onChanged: (v) => checkout.deliveryEta.value = v!,
        ),
      ),
    );
  }

  Widget _paymentTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Obx(
      () => ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: Theme.of(Get.context!).cardColor,
        leading: Icon(icon),
        title: Text(label),
        trailing: Radio<String>(
          value: value,
          groupValue: checkout.payment.value,
          onChanged: (v) => checkout.payment.value = v!,
        ),
      ),
    );
  }
}
