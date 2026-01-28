import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/banner_controller.dart';

import 'widgets/admin_kpi_card.dart';
import 'widgets/admin_analytics_chart.dart';
import 'widgets/revenue_trend_chart.dart';
import 'widgets/order_status_analytics.dart';
import 'widgets/top_products_widget.dart';

import 'admin_banner_page.dart' hide BannerController;

class AdminDashboardView extends StatelessWidget {
  AdminDashboardView({super.key});

  final ProductController products = Get.find<ProductController>();
  final OrdersController orders = Get.find<OrdersController>();
  final SessionController session = Get.find<SessionController>();
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final BannerController bannerCtrl = Get.put(BannerController()); // singleton

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  themeCtrl.isDark.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: themeCtrl.toggleTheme,
              )),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              session.logout();
              Get.offAllNamed("/login");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== HEADER =====
            _glassHeader(),

            const SizedBox(height: 24),

            // ===== KPI =====
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: AdminKpiCard(
                        title: "Products",
                        value: products.products.length.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: Colors.indigo,
                        shadowColor: Colors.indigo.withAlpha((0.35 * 255).toInt()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminKpiCard(
                        title: "Orders",
                        value: orders.adminTotalOrders.toString(),
                        icon: Icons.shopping_cart_checkout_rounded,
                        color: Colors.deepPurple,
                        shadowColor: Colors.deepPurple.withAlpha((0.35 * 255).toInt()),
                      ),
                    ),
                  ],
                )),

            const SizedBox(height: 32),

            // ===== QUICK ACTIONS =====
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 12),

            _actionTile(
              icon: Icons.inventory_rounded,
              title: "Product Management",
              subtitle: "Add, update & delete products",
              onTap: () => Get.toNamed("/admin-products"),
            ),
            const SizedBox(height: 12),
            _actionTile(
              icon: Icons.receipt_long_rounded,
              title: "Order Management",
              subtitle: "Track & process orders",
              onTap: () => Get.toNamed("/admin-orders"),
            ),
            const SizedBox(height: 12),

            // ===== Banner Management =====
            _actionTile(
              icon: Icons.photo_rounded,
              title: "Manage Banner",
              subtitle: "Add or update home page banner",
              onTap: () => Get.to(() => AdminBannerPage()),
            ),

            const SizedBox(height: 20),

            // ===== TOTAL REVENUE =====
            Obx(() => _totalRevenueHighlight(
                  "₹${orders.adminTotalRevenue.toStringAsFixed(2)}",
                )),

            const SizedBox(height: 36),

            // ===== ANALYTICS =====
            _sectionTitle("Order Analytics"),
            const SizedBox(height: 12),
            AdminAnalyticsChart(),

            const SizedBox(height: 28),

            _sectionTitle("Revenue Growth"),
            const SizedBox(height: 12),
            RevenueTrendChart(),

            const SizedBox(height: 24),

            OrderStatusAnalytics(),

            const SizedBox(height: 24),

            TopProductsWidget(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

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
            color: Colors.black.withAlpha((0.28 * 255).toInt()),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white, size: 42),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Admin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Business performance overview",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _totalRevenueHighlight(String value) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withAlpha((0.45 * 255).toInt()),
            blurRadius: 28,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.18 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Revenue",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}