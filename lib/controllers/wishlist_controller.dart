import 'package:get/get.dart';
import '../models/product_model.dart';
import 'session_controller.dart';

class WishlistController extends GetxController {
  final SessionController session = Get.find<SessionController>();

  // 🔐 userEmail -> wishlist items
  final RxMap<String, List<ProductModel>> _userWishlists =
      <String, List<ProductModel>>{}.obs;

  // ---------------- CURRENT USER KEY ----------------
  String get _key => session.currentUser.value?.email ?? "";

  // ---------------- WISHLIST ITEMS (USER ONLY) ----------------
  List<ProductModel> get items {
    if (_key.isEmpty) return [];
    return _userWishlists[_key] ?? [];
  }

  // ---------------- CHECK ----------------
  bool isWishlisted(ProductModel p) {
    return items.any((e) => e.id == p.id);
  }

  // ---------------- TOGGLE ----------------
  void toggle(ProductModel p) {
    isWishlisted(p) ? remove(p) : add(p);
  }

  // ---------------- ADD ----------------
  void add(ProductModel p) {
    if (_key.isEmpty) return;

    final list = List<ProductModel>.from(_userWishlists[_key] ?? []);
    list.add(p);
    _userWishlists[_key] = list;
  }

  // ---------------- REMOVE ----------------
  void remove(ProductModel p) {
    if (_key.isEmpty) return;

    final list = List<ProductModel>.from(_userWishlists[_key] ?? []);
    list.removeWhere((e) => e.id == p.id);
    _userWishlists[_key] = list;
  }

  // ---------------- CLEAR ON LOGOUT ----------------
  void clearOnLogout() {
    if (_key.isNotEmpty) {
      _userWishlists.remove(_key);
    }
  }
}
