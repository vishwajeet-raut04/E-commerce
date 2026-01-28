import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/product_controller.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late ProductModel product;

  final CartController cart = Get.find<CartController>();
  final WishlistController wishlist = Get.find<WishlistController>();
  final ProductController products = Get.find<ProductController>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = Get.arguments as ProductModel; // ✅ FIX
  }

  // ================= IMAGE =================
  Widget _productImage(String path) {
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
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ================= SIMILAR =================
  List<ProductModel> _similarProducts() {
    return products.products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool isOut = product.stock == 0;
    final bool isLow = product.stock > 0 && product.stock <= 3;
    final similar = _similarProducts();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          Obx(() {
            final fav = wishlist.isWishlisted(product);
            return IconButton(
              icon: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? cs.error : cs.onSurfaceVariant,
              ),
              onPressed: () => wishlist.toggle(product),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            Hero(
              tag: "product-${product.id}",
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: _productImage(product.imagePath),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "₹${product.price}",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (isOut)
                      _statusChip("Out of Stock", cs.error)
                    else if (isLow)
                      _statusChip(
                        "Hurry! Only ${product.stock} left",
                        Colors.orange,
                      )
                    else
                      _statusChip(
                        "In Stock (${product.stock})",
                        Colors.green,
                      ),

                    const SizedBox(height: 22),

                    Text(
                      "Description",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                    // ================= SIMILAR PRODUCTS =================
                    if (similar.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        "Similar Products",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: similar.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final p = similar[i];
                            final out = p.stock == 0;

                            return GestureDetector(
                              onTap: out
                                  ? null
                                  : () {
                                      // ✅ ONLY NAVIGATION FIX
                                      Get.to(
                                        () => const ProductDetailsView(),
                                        arguments: p,
                                        preventDuplicates: false,
                                      );
                                    },
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Hero(
                                      tag: "product-${p.id}",
                                      child: SizedBox(
                                        height: 120,
                                        width: double.infinity,
                                        child: _productImage(p.imagePath),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        p.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isOut ? null : () => cart.add(product),
                        child: Text(isOut ? "Out of Stock" : "Add to Cart"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
