class ProductModel {
  String id;
  String name;
  double price;
  String category;
  String description;
  String imagePath;
  int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imagePath,
    this.stock = 1,
  });
}
