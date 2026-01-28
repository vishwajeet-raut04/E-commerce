import 'package:get/get.dart';
import '../models/product_model.dart';
import 'session_controller.dart';

class CartController extends GetxController {
  final SessionController session = Get.find<SessionController>();

  // 🔐 userEmail -> cart items
  final RxMap<String, List<ProductModel>> _userCarts =
      <String, List<ProductModel>>{}.obs;

  // ---------------- CURRENT USER KEY ----------------
  String get _key => session.currentUser.value?.email ?? "";

  // ---------------- CART ITEMS (USER ONLY) ----------------
  List<ProductModel> get cartItems {
    if (_key.isEmpty) return [];
    return _userCarts[_key] ?? [];
  }

  // ---------------- COUNTS ----------------
  int get count => cartItems.length;

  double get total => cartItems.fold(0.0, (sum, item) => sum + item.price);

  // ---------------- ADD ----------------
  void add(ProductModel product) {
    if (_key.isEmpty) return;

    final list = List<ProductModel>.from(_userCarts[_key] ?? []);
    list.add(product);
    _userCarts[_key] = list;
  }

  // ---------------- REMOVE SINGLE ITEM ----------------
  void remove(ProductModel product) {
    if (_key.isEmpty) return;

    final list = List<ProductModel>.from(_userCarts[_key] ?? []);
    list.removeWhere((e) => e.id == product.id);
    _userCarts[_key] = list;
  }

  // ---------------- CLEAR (CHECKOUT SAFE) ----------------
  void clearCart() {
    if (_key.isEmpty) return;
    _userCarts[_key] = [];
  }

  // ---------------- CLEAR ON LOGOUT ----------------
  void clearOnLogout() {
    if (_key.isNotEmpty) {
      _userCarts.remove(_key);
    }
  }
}
