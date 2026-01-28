import 'product_model.dart';

class OrderModel {
  // ================= CORE =================
  final String id;
  final String userEmail;

  final List<ProductModel> items;
  final double total;

  // ================= DELIVERY & PAYMENT =================
  final String paymentMethod;
  final String address;
  final String mobile;
  final String deliveryType;

  // ================= STATUS =================
  final String status;

  // ================= ANALYTICS =================
  final DateTime createdAt;

  // ================= CONSTRUCTOR =================
  OrderModel({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.address,
    required this.mobile,
    required this.deliveryType,
    this.status = "Placed",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // =====================================================
  // ================= IMMUTABLE UPDATE =================
  // =====================================================

  OrderModel copyWith({
    String? id,
    String? userEmail,
    List<ProductModel>? items,
    double? total,
    String? paymentMethod,
    String? address,
    String? mobile,
    String? deliveryType,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =====================================================
  // ================= HELPERS ===========================
  // =====================================================

  bool get isCancelled => status == "Cancelled";
  bool get isDelivered => status == "Delivered";
  bool get isActive => !isCancelled && !isDelivered;

  int get itemCount => items.length;
}
