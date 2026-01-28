import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/session_controller.dart';
import '../../controllers/wishlist_controller.dart';

class UserAccountView extends StatelessWidget {
  UserAccountView({super.key});

  final session = Get.find<SessionController>();
  final wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Account"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= PROFILE CARD =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _card(theme),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.primaryColor,
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Signed in as",
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      session.currentUser.value?.email ?? "",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= WISHLIST =================
          Obx(() => _tile(
                theme: theme,
                icon: Icons.favorite_border,
                label: "My Wishlist",
                trailing: wishlist.items.isEmpty
                    ? null
                    : _countBadge(
                        wishlist.items.length,
                        theme,
                      ),
                onTap: () => Get.toNamed("/wishlist"),
              )),

          // ================= ORDERS =================
          _tile(
            theme: theme,
            icon: Icons.shopping_bag_outlined,
            label: "My Orders",
            onTap: () => Get.toNamed("/user-orders"),
          ),

          // ================= ADDRESSES =================
          _tile(
            theme: theme,
            icon: Icons.location_on_outlined,
            label: "Saved Addresses",
            onTap: () {
              Get.snackbar(
                "Coming Soon",
                "Address management will be available soon",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),

          const SizedBox(height: 12),

          // ================= LOGOUT =================
          _tile(
            theme: theme,
            icon: Icons.logout,
            label: "Logout",
            color: Colors.redAccent,
            onTap: () {
              session.logout();
              Get.offAllNamed("/login");
            },
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  BoxDecoration _card(ThemeData theme) => BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      );

  Widget _tile({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    final effectiveColor = color ?? theme.iconTheme.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _card(theme),
      child: ListTile(
        leading: Icon(icon, color: effectiveColor),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: effectiveColor,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color,
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _countBadge(int count, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
