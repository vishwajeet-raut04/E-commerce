import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  // ================= STATE =================
  final products = <ProductModel>[].obs;

  // Search & category filter
  final searchQuery = "".obs;
  final selectedCategory = "All".obs;

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    _seedDemoProducts();
  }

  // ================= DEMO PRODUCTS =================
  void _seedDemoProducts() {
    if (products.isNotEmpty) return;

    products.addAll([
      // ================= ELECTRONICS =================
      ProductModel(
        id: "1",
        name: "iPhone 14",
        price: 69999,
        category: "Electronics",
        description: "Apple smartphone with A15 Bionic chip",
        imagePath: "assets/images/phone.png",
        stock: 5,
      ),
      ProductModel(
        id: "2",
        name: "Gaming Laptop",
        price: 89999,
        category: "Electronics",
        description: "High-performance gaming laptop",
        imagePath: "assets/images/laptop.png",
        stock: 0,
      ),
      ProductModel(
        id: "3",
        name: "Bluetooth Headphones",
        price: 3499,
        category: "Electronics",
        description: "Wireless noise-cancelling headphones",
        imagePath: "assets/images/headphones.png",
        stock: 10,
      ),

      // ================= MEN =================
      ProductModel(
        id: "5",
        name: "Men's Cotton Shirt",
        price: 1499,
        category: "Men",
        description: "Slim-fit cotton shirt",
        imagePath: "assets/images/shirt.png",
        stock: 12,
      ),
      ProductModel(
        id: "6",
        name: "Men's Denim Jeans",
        price: 2499,
        category: "Men",
        description: "Regular fit blue denim jeans",
        imagePath: "assets/images/jeans.png",
        stock: 6,
      ),

      // ================= WOMEN =================
      ProductModel(
        id: "7",
        name: "Women's Kurti",
        price: 1999,
        category: "Women",
        description: "Elegant printed kurti",
        imagePath: "assets/images/kurti.png",
        stock: 9,
      ),
      ProductModel(
        id: "8",
        name: "Women's Handbag",
        price: 2799,
        category: "Women",
        description: "Stylish leather handbag",
        imagePath: "assets/images/handbag.png",
        stock: 4,
      ),

      // ================= FOOTWEAR =================
      ProductModel(
        id: "9",
        name: "Running Shoes",
        price: 2999,
        category: "Footwear",
        description: "Lightweight sports shoes",
        imagePath: "assets/images/shoes.png",
        stock: 8,
      ),
      ProductModel(
        id: "10",
        name: "Casual Sneakers",
        price: 2499,
        category: "Footwear",
        description: "Comfortable everyday sneakers",
        imagePath: "assets/images/sneakers.png",
        stock: 0,
      ),

      // ================= HOME =================
      ProductModel(
        id: "11",
        name: "Electric Kettle",
        price: 1999,
        category: "Home",
        description: "1.5L stainless steel kettle",
        imagePath: "assets/images/kettle.png",
        stock: 5,
      ),
      ProductModel(
        id: "12",
        name: "Table Lamp",
        price: 1299,
        category: "Home",
        description: "Modern bedside lamp",
        imagePath: "assets/images/lamp.png",
        stock: 11,
      ),

      // ================= BEAUTY =================
      ProductModel(
        id: "13",
        name: "Face Moisturizer",
        price: 899,
        category: "Beauty",
        description: "Hydrating daily face cream",
        imagePath: "assets/images/cream.png",
        stock: 15,
      ),
      ProductModel(
        id: "14",
        name: "Hair Dryer",
        price: 2199,
        category: "Beauty",
        description: "Quick-dry professional hair dryer",
        imagePath: "assets/images/hairdryer.png",
        stock: 3,
      ),

      // ================= SPORTS =================
      ProductModel(
        id: "15",
        name: "Yoga Mat",
        price: 999,
        category: "Sports",
        description: "Non-slip yoga mat",
        imagePath: "assets/images/yogamat.png",
        stock: 14,
      ),
      ProductModel(
        id: "16",
        name: "Dumbbell Set",
        price: 3499,
        category: "Sports",
        description: "Adjustable dumbbell set",
        imagePath: "assets/images/dumbbell.png",
        stock: 2,
      ),

      // ================= ACCESSORIES =================
      ProductModel(
        id: "17",
        name: "Sunglasses",
        price: 1599,
        category: "Accessories",
        description: "UV-protected stylish sunglasses",
        imagePath: "assets/images/sunglasses.png",
        stock: 6,
      ),
      ProductModel(
        id: "18",
        name: "Leather Wallet",
        price: 1199,
        category: "Accessories",
        description: "Genuine leather wallet",
        imagePath: "assets/images/wallet.png",
        stock: 9,
      ),
    ]);
  }

  // ================= FILTERED PRODUCTS =================
  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value == "All" ||
          p.category == selectedCategory.value;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ================= CATEGORIES =================
  List<String> get categories {
    final set = products.map((p) => p.category).toSet().toList();
    set.sort();
    return ["All", ...set];
  }

  // ================= CRUD =================
  void addProduct(ProductModel p) {
    products.add(p);
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
  }

  // ================= STOCK =================
  void reduceStock(String productId) {
    final product = products.firstWhere((p) => p.id == productId);
    if (product.stock > 0) {
      product.stock--;
      products.refresh();
    }
  }

  // ================= CONTROLS =================
  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
  }
}
