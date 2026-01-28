import 'package:get/get.dart';

import '../models/order_model.dart';
import 'cart_controller.dart';
import 'orders_controller.dart';
import 'product_controller.dart';
import 'session_controller.dart';

class CheckoutController extends GetxController {
  // ================= FORM STATE =================
  final address = "".obs;
  final mobile = "".obs;

  // Payment + Delivery
  final payment = "Cash on Delivery".obs;

  /// Values used by UI dropdown / radio
  final deliveryEta = "Standard (2–4 days)".obs;

  // ================= DELIVERY PRICING =================
  static const double expressFee = 99.0;

  bool get isExpress => deliveryEta.value.toLowerCase().contains("express");

  double get deliveryFee => isExpress ? expressFee : 0.0;

  double get finalTotal => cart.total + deliveryFee;

  // ================= DEPENDENCIES =================
  final CartController cart = Get.find<CartController>();
  final OrdersController orders = Get.find<OrdersController>();
  final ProductController products = Get.find<ProductController>();
  final SessionController session = Get.find<SessionController>();

  // ================= VALIDATION =================
  bool validate() {
    if (address.value.trim().isEmpty) {
      Get.snackbar("Error", "Please enter delivery address");
      return false;
    }

    if (mobile.value.trim().length < 10) {
      Get.snackbar("Error", "Please enter a valid mobile number");
      return false;
    }

    if (cart.cartItems.isEmpty) {
      Get.snackbar("Error", "Your cart is empty");
      return false;
    }

    if (session.currentUser.value == null) {
      Get.snackbar("Session Error", "Please login again");
      return false;
    }

    return true;
  }

  // ================= CREATE ORDER =================
  OrderModel createOrder() {
    final user = session.currentUser.value!;

    return OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userEmail: user.email,
      items: List.from(cart.cartItems),
      total: finalTotal, // ✅ EXPRESS FEE INCLUDED
      status: "Placed",
      address: address.value,
      mobile: mobile.value,
      paymentMethod: payment.value,
      deliveryType: isExpress ? "Express" : "Standard",
      createdAt: DateTime.now(),
    );
  }

  // ================= PLACE ORDER =================
  void placeOrder() {
    if (!validate()) return;

    final order = createOrder();

    // -------- SAVE ORDER --------
    orders.placeOrder(order);

    // -------- REDUCE STOCK --------
    for (final item in cart.cartItems) {
      products.reduceStock(item.id);
    }

    // -------- CLEAR CART --------
    cart.clearCart();

    // -------- RESET FORM --------
    resetForm();

    // -------- SUCCESS --------
    Get.snackbar(
      "Order Placed",
      isExpress
          ? "Express delivery selected (+₹$expressFee)"
          : "Standard delivery selected",
    );
  }

  // ================= RESET =================
  void resetForm() {
    address.value = "";
    mobile.value = "";
    payment.value = "Cash on Delivery";
    deliveryEta.value = "Standard (2–4 days)";
  }
}
