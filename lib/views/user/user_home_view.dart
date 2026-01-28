import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/banner_controller.dart';

class UserHomeView extends StatelessWidget {
  UserHomeView({super.key});

  final products = Get.find<ProductController>();
  final theme = Get.find<ThemeController>();
  final bannerCtrl = Get.find<BannerController>();

  // ================= SAFE PRODUCT IMAGE =================
  Widget _productImage(String path) {
    if (path.isEmpty) return _placeholder();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 1, // 🔑 same size for all products
        child: path.startsWith("assets/")
            ? Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.withOpacity(0.12),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  // ================= BADGE =================
  Widget _badge(String text, Color color) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= BANNER SLIDER =================
  Widget _bannerSlider() {
    return Obx(() {
      // ✅ NO banner → show nothing (normal UI)
      if (bannerCtrl.banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              itemCount: bannerCtrl.banners.length,
              onPageChanged: (i) {
                if (i < bannerCtrl.banners.length) {
                  bannerCtrl.changeIndex(i);
                }
              },
              itemBuilder: (_, index) {
                final path = bannerCtrl.banners[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: path.startsWith("assets/")
                        ? Image.asset(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                  ),
                );
              },
            ),
          ),

          // dots only if more than 1 banner
          if (bannerCtrl.banners.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerCtrl.banners.length,
                (i) => Container(
                  margin: const EdgeInsets.all(4),
                  width: bannerCtrl.currentIndex.value == i ? 10 : 6,
                  height: bannerCtrl.currentIndex.value == i ? 10 : 6,
                  decoration: BoxDecoration(
                    color: bannerCtrl.currentIndex.value == i
                        ? Colors.blue
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDark = themeData.brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ================= SEARCH BAR =================
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: themeData.scaffoldBackgroundColor,
            toolbarHeight: 72,
            title: TextField(
              onChanged: products.updateSearch,
              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              Obx(() => IconButton(
                    icon: Icon(
                      theme.isDark.value
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: theme.toggleTheme,
                  )),
            ],
          ),

          // ================= BANNER =================
          SliverToBoxAdapter(child: _bannerSlider()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ================= CATEGORY =================
          SliverToBoxAdapter(
            child: Obx(() {
              if (products.categories.length <= 1) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final category = products.categories[index];
                    final isSelected =
                        category == products.selectedCategory.value;

                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: themeData.primaryColor,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) =>
                          products.selectCategory(category),
                    );
                  },
                ),
              );
            }),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ================= PRODUCT GRID =================
          Obx(() {
            final list = products.filteredProducts;

            if (list.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text(
                    "No products found",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    final p = list[index];
                    final isOut = p.stock == 0;
                    final isLow = p.stock > 0 && p.stock <= 3;

                    return GestureDetector(
                      onTap: isOut
                          ? null
                          : () => Get.toNamed(
                                "/product",
                                arguments: p,
                              ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeData.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: "product-${p.id}",
                                    child: _productImage(p.imagePath),
                                  ),
                                  if (isOut)
                                    _badge(
                                        "OUT OF STOCK", Colors.redAccent),
                                  if (isLow)
                                    _badge(
                                        "ONLY ${p.stock} LEFT",
                                        Colors.orangeAccent),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${p.price}",
                                    style: TextStyle(
                                      color: themeData.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}