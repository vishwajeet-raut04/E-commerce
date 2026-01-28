import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  final ProductController productController = Get.find<ProductController>();
  final ImagePicker picker = ImagePicker();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  final RxString pickedImagePath = "".obs;

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    categoryCtrl.dispose();
    descCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  // ================= IMAGE PICKER =================
  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) pickedImagePath.value = img.path;
  }

  // ================= SAFE IMAGE =================
  Widget _adminImage(String path) {
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.grey);

    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }
    return Image.file(file, fit: BoxFit.cover);
  }

  // ================= ADD / EDIT =================
  void openProductDialog({ProductModel? product}) {
    if (product != null) {
      nameCtrl.text = product.name;
      priceCtrl.text = product.price.toString();
      categoryCtrl.text = product.category;
      descCtrl.text = product.description;
      stockCtrl.text = product.stock.toString();
      pickedImagePath.value = product.imagePath;
    } else {
      nameCtrl.clear();
      priceCtrl.clear();
      categoryCtrl.clear();
      descCtrl.clear();
      stockCtrl.clear();
      pickedImagePath.value = "";
    }

    Get.dialog(
      AlertDialog(
        title: Text(product == null ? "Add Product" : "Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field(nameCtrl, "Product Name"),
              _field(priceCtrl, "Price", keyboard: TextInputType.number),
              _field(stockCtrl, "Stock", keyboard: TextInputType.number),
              _field(categoryCtrl, "Category"),
              _field(descCtrl, "Description", maxLines: 3),
              const SizedBox(height: 10),
              Obx(() => SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: pickedImagePath.value.isEmpty
                        ? const Center(child: Text("No image selected"))
                        : _adminImage(pickedImagePath.value),
                  )),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty ||
                  priceCtrl.text.isEmpty ||
                  categoryCtrl.text.isEmpty ||
                  stockCtrl.text.isEmpty) {
                Get.snackbar("Error", "All fields are required");
                return;
              }

              final price = double.tryParse(priceCtrl.text);
              final stock = int.tryParse(stockCtrl.text);

              if (price == null || stock == null) {
                Get.snackbar("Error", "Invalid price or stock");
                return;
              }

              if (product == null) {
                productController.addProduct(
                  ProductModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    price: price,
                    category: categoryCtrl.text,
                    description: descCtrl.text,
                    imagePath: pickedImagePath.value,
                    stock: stock,
                  ),
                );
              } else {
                product.name = nameCtrl.text;
                product.price = price;
                product.category = categoryCtrl.text;
                product.description = descCtrl.text;
                product.imagePath = pickedImagePath.value;
                product.stock = stock;
                productController.products.refresh();
                Get.snackbar("Updated", "Product updated");
              }

              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openProductDialog(),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final list = productController.filteredProducts;

        if (list.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];

            return Card(
              child: ListTile(
                leading: SizedBox(
                  width: 48,
                  height: 48,
                  child: _adminImage(p.imagePath),
                ),
                title: Text(p.name),
                subtitle:
                    Text("₹${p.price} • ${p.category} • Stock: ${p.stock}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == "edit") {
                      openProductDialog(product: p);
                    } else if (v == "delete") {
                      Get.dialog(
                        AlertDialog(
                          title: const Text("Delete Product"),
                          content: const Text("This action cannot be undone."),
                          actions: [
                            TextButton(
                                onPressed: Get.back,
                                child: const Text("Cancel")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                productController.deleteProduct(p.id);
                                Get.back();
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
