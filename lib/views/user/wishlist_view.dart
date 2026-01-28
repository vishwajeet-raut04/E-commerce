import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';

class WishlistView extends StatelessWidget {
  WishlistView({super.key});

  final WishlistController wishlist = Get.find<WishlistController>();
  final CartController cart = Get.find<CartController>();

  // ================= SAFE IMAGE =================
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
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text("My Wishlist"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        if (wishlist.items.isEmpty) {
          return _empty(theme);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: wishlist.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final ProductModel p = wishlist.items[index];
            final bool isOut = p.stock == 0;

            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  // ================= IMAGE =================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: _image(p.imagePath),
                    ),
                  ),

                  // ================= DETAILS =================
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "₹${p.price}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ================= ACTIONS =================
                          Row(
                            children: [
                              // ADD TO CART
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isOut ? cs.outline : cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: isOut
                                    ? null
                                    : () {
                                        cart.add(p);
                                        Get.snackbar(
                                          "Added to Cart",
                                          p.name,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                child: Text(
                                  isOut ? "Out" : "Add",
                                ),
                              ),

                              const SizedBox(width: 8),

                              // REMOVE
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: cs.error,
                                ),
                                onPressed: () => wishlist.remove(p),
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
        );
      }),
    );
  }

  // ================= EMPTY STATE =================

  Widget _empty(ThemeData theme) {
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 72,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            "Your wishlist is empty",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            "Save products you love",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
