import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';

import 'user_home_view.dart';
import 'cart_view.dart';
import 'user_orders_view.dart';
import 'user_account_view.dart';
import 'user_menu_view.dart';

class UserRootView extends StatelessWidget {
  UserRootView({super.key});

  final UserNavController nav = Get.put(UserNavController());

  final List<Widget> pages = [
    UserHomeView(),
    CartView(),
    UserOrdersView(),
    UserAccountView(),
    UserMenuView(),
  ];

  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.shopping_cart_outlined,
    Icons.inventory_2_outlined,
    Icons.person_outline,
    Icons.menu,
  ];

  final List<String> labels = const [
    "Home",
    "Cart",
    "Orders",
    "Account",
    "Menu",
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: nav.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              final bool isSelected = nav.currentIndex.value == index;

              return GestureDetector(
                onTap: () => nav.changeTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index],
                        size: isSelected ? 26 : 22,
                        color: isSelected ? Colors.deepPurple : Colors.grey,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.deepPurple : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
