import 'package:get/get.dart';
import '../models/user_model.dart';
import '../views/user/user_root_view.dart';

// 🔗 DEPENDENCIES
import 'cart_controller.dart';
import 'wishlist_controller.dart';

class SessionController extends GetxController {
  // ================= AUTH STATE =================
  final isLoggedIn = false.obs;
  final isAdmin = false.obs;

  // ================= USER STORAGE (OFFLINE / MEMORY) =================
  final RxList<UserModel> users = <UserModel>[
    UserModel(email: "user1@gmail.com", password: "1234"),
    UserModel(email: "user2@gmail.com", password: "abcd"),
  ].obs;

  // ================= CURRENT USER =================
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // ================= SIGNUP =================
  void signup(String email, String password) {
    final e = email.trim().toLowerCase();

    if (e.isEmpty || password.trim().isEmpty) {
      Get.snackbar("Error", "Email and password cannot be empty");
      return;
    }

    if (users.any((u) => u.email.toLowerCase() == e)) {
      Get.snackbar("Error", "User already exists");
      return;
    }

    users.add(
      UserModel(email: e, password: password),
    );

    Get.snackbar("Success", "Account created successfully");
    Get.offAllNamed("/login");
  }

  // ================= USER LOGIN =================
  void login(String email, String password) {
    final e = email.trim().toLowerCase();

    try {
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == e &&
            u.password == password,
      );

      currentUser.value = user;
      isLoggedIn.value = true;
      isAdmin.value = false;

      Get.offAll(() => UserRootView());
    } catch (_) {
      Get.snackbar("Error", "Invalid email or password");
    }
  }

  // ================= FORGOT / RESET PASSWORD =================
  void resetPassword(String email, String newPassword) {
    final e = email.trim().toLowerCase();

    for (int i = 0; i < users.length; i++) {
      if (users[i].email.toLowerCase() == e) {
        users[i] = UserModel(
          email: users[i].email,
          password: newPassword,
        );

        Get.snackbar("Success", "Password updated successfully");
        Get.offAllNamed("/login");
        return;
      }
    }

    Get.snackbar("Error", "Email not found");
  }

  // ================= ADMIN LOGIN =================
  void loginAdmin(String email, String password) {
    isLoggedIn.value = true;
    isAdmin.value = true;
    currentUser.value = null;

    Get.offAllNamed("/admin-dashboard");
  }

  // ================= LOGOUT =================
  void logout() {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearOnLogout();
    }

    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().clearOnLogout();
    }

    isLoggedIn.value = false;
    isAdmin.value = false;
    currentUser.value = null;

    Get.offAllNamed("/login");
  }

  // ================= DEBUG =================
  void debugUsers() {
    print(users.map((u) => u.email).toList());
  }
}