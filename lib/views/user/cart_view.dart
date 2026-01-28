import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartController cart = Get.find<CartController>();

  final Map<String, int> quantities = {};
  final TextEditingController couponCtrl = TextEditingController();
  double discount = 0;

  // ================= IMAGE =================
  Widget _image(String path) {
    if (path.isEmpty) return _placeholder();

    if (path.startsWith("assets/")) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.withOpacity(0.15),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  int _qty(ProductModel p) => quantities[p.id] ?? 1;

  void _inc(ProductModel p) {
    setState(() => quantities[p.id] = _qty(p) + 1);
  }

  void _dec(ProductModel p) {
    if (_qty(p) <= 1) return;
    setState(() => quantities[p.id] = _qty(p) - 1);
  }

  double get total {
    double sum = 0;
    for (final p in cart.cartItems) {
      sum += p.price * _qty(p);
    }
    return (sum - discount).clamp(0, double.infinity);
  }

  void applyCoupon() {
    if (couponCtrl.text.trim().toUpperCase() == "SAVE10") {
      setState(() => discount = total * 0.10);
      Get.snackbar("Coupon Applied", "You saved 10%");
    } else {
      Get.snackbar("Invalid Coupon", "Try SAVE10");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Cart"),
        elevation: 0,
      ),
      body: Obx(() {
        if (cart.cartItems.isEmpty) return _empty(theme);

        return Column(
          children: [
            // ================= ITEMS =================
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: cart.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final ProductModel p = cart.cartItems[i];

                  return Container(
                    decoration: _card(theme),
                    child: Row(
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 90,
                            width: 90,
                            child: _image(p.imagePath),
                          ),
                        ),

                        // DETAILS
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${p.price}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // QUANTITY + REMOVE
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () => _dec(p), theme),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        _qty(p).toString(),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _qtyBtn(Icons.add, () => _inc(p), theme),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        cart.remove(p);
                                        quantities.remove(p.id);

                                        Get.snackbar(
                                          "Removed",
                                          "${p.name} removed from cart",
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ================= COUPON =================
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponCtrl,
                      decoration: const InputDecoration(
                        hintText: "Promo code",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: applyCoupon,
                    child: const Text("Apply"),
                  ),
                ],
              ),
            ),

            // ================= TOTAL =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _footer(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row("Delivery", "Free • 2–4 days", theme),
                  if (discount > 0)
                    _row(
                      "Discount",
                      "-₹${discount.toStringAsFixed(2)}",
                      theme,
                      color: Colors.green,
                    ),
                  const SizedBox(height: 6),
                  _row(
                    "Total",
                    "₹${total.toStringAsFixed(2)}",
                    theme,
                    bold: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed("/checkout"),
                      child: const Text("Proceed to Checkout"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= UI HELPERS =================

  BoxDecoration _card(ThemeData theme) => BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      );

  BoxDecoration _footer(ThemeData theme) => BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      );

  Widget _qtyBtn(IconData icon, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    ThemeData theme, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color ?? theme.textTheme.bodyMedium?.color,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _empty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            "Your cart is empty",
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
