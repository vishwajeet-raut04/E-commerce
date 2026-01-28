import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/session_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/checkout_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/banner_controller.dart'; // ✅ Added

// ---------------- AUTH VIEWS ----------------
import 'views/auth/login_view.dart';
import 'views/auth/signup_view.dart' hide LoginView;
import 'views/auth/forgot_password_screen.dart';

// ---------------- USER VIEWS ----------------
import 'views/user/user_root_view.dart';
import 'views/user/user_home_view.dart';
import 'views/user/product_details_view.dart';
import 'views/user/cart_view.dart';
import 'views/user/checkout_view.dart';
import 'views/user/user_orders_view.dart';
import 'views/user/wishlist_view.dart';

// ---------------- ADMIN VIEWS ----------------
import 'views/admin/admin_dashboard_view.dart';
import 'views/admin/admin_orders_view.dart';
import 'views/admin/admin_products_view.dart';

// ---------------- MIDDLEWARE ----------------
import 'middlewares/admin_guard.dart';

void main() {
  // ================= GLOBAL CONTROLLERS =================
  Get.put(SessionController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(OrdersController(), permanent: true);
  Get.put(CheckoutController(), permanent: true);
  Get.put(WishlistController(), permanent: true);
  Get.put(ThemeController(), permanent: true); // 🌙 Dark mode
  Get.put(BannerController(), permanent: true); // ✅ BannerController added

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Offline Ecommerce',
          initialRoute: "/login",

          // ================= THEME MODE =================
          themeMode: theme.isDark.value ? ThemeMode.dark : ThemeMode.light,

          // ================= LIGHT THEME =================
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF6F7FB),
            primaryColor: const Color(0xFF5B2EFF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1F2937),
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2EFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // ================= DARK THEME =================
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF6366F1),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF020617),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF020617),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            dialogBackgroundColor: const Color(0xFF020617),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF020617),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.white54),
            ),
            iconTheme: const IconThemeData(color: Colors.white70),
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              bodyMedium: TextStyle(
                color: Colors.white70,
              ),
              bodySmall: TextStyle(
                color: Colors.white54,
              ),
            ),
          ),

          // ================= ROUTES =================
          getPages: [
            // AUTH
            GetPage(name: "/login", page: () => LoginView()),
            GetPage(name: "/signup", page: () => SignupView()),
            GetPage(name: "/forgot-password", page: () => ForgotPasswordScreen()),

            // USER
            GetPage(name: "/user-root", page: () => UserRootView()),
            GetPage(name: "/user-home", page: () => UserHomeView()),
            GetPage(name: "/product", page: () => ProductDetailsView()),
            GetPage(name: "/cart", page: () => CartView()),
            GetPage(name: "/checkout", page: () => CheckoutView()),
            GetPage(name: "/user-orders", page: () => UserOrdersView()),
            GetPage(name: "/wishlist", page: () => WishlistView()),

            // ADMIN
            GetPage(
              name: "/admin-dashboard",
              page: () => AdminDashboardView(),
              middlewares: [AdminGuard()],
            ),
            GetPage(
              name: "/admin-products",
              page: () => AdminProductsView(),
              middlewares: [AdminGuard()],
            ),
            GetPage(
              name: "/admin-orders",
              page: () => AdminOrdersView(),
              middlewares: [AdminGuard()],
            ),
          ],
        ));
  }
}