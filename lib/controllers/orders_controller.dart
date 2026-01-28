import 'package:get/get.dart';
import '../models/order_model.dart';
import 'product_controller.dart';
import 'session_controller.dart';

// ================= TIME FILTER =================
enum TimeFilter { today, last7Days, last30Days, all }

extension TimeFilterLabel on TimeFilter {
  String get label {
    switch (this) {
      case TimeFilter.today:
        return "Today";
      case TimeFilter.last7Days:
        return "7 Days";
      case TimeFilter.last30Days:
        return "30 Days";
      case TimeFilter.all:
        return "All";
    }
  }
}

class OrdersController extends GetxController {
  // ================= STATE =================
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<TimeFilter> selectedFilter = TimeFilter.all.obs;

  final SessionController session = Get.find<SessionController>();

  // ================= PLACE ORDER =================
  void placeOrder(OrderModel order) {
    orders.insert(0, order); // newest first
  }

  // =====================================================
  // ================= USER ORDERS =======================
  // =====================================================

  List<OrderModel> get userOrders {
    final email = session.currentUser.value?.email;
    if (email == null) return [];
    return orders.where((o) => o.userEmail == email).toList();
  }

  // =====================================================
  // ================= USER FILTERING ====================
  // =====================================================

  List<OrderModel> get filteredOrders {
    final now = DateTime.now();

    return userOrders.where((o) {
      final created = o.createdAt;

      switch (selectedFilter.value) {
        case TimeFilter.today:
          return created.year == now.year &&
              created.month == now.month &&
              created.day == now.day;

        case TimeFilter.last7Days:
          return created.isAfter(now.subtract(const Duration(days: 7)));

        case TimeFilter.last30Days:
          return created.isAfter(now.subtract(const Duration(days: 30)));

        case TimeFilter.all:
          return true;
      }
    }).toList();
  }

  // =====================================================
  // ================= ADMIN ANALYTICS ===================
  // =====================================================

  int get adminTotalOrders => orders.length;

  double get adminTotalRevenue => orders
      .where((o) => o.status != "Cancelled")
      .fold(0.0, (sum, o) => sum + o.total);

  Map<String, int> get adminStatusCount {
    final Map<String, int> map = {
      "Placed": 0,
      "Packed": 0,
      "Shipped": 0,
      "Delivered": 0,
      "Cancelled": 0,
    };

    for (final o in orders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  List<double> get adminRevenueTrend {
    double sum = 0;
    final List<double> points = [];

    for (final o in orders) {
      if (o.status != "Cancelled") {
        sum += o.total;
        points.add(sum);
      }
    }
    return points;
  }

  Map<String, int> get adminProductSales {
    final Map<String, int> map = {};

    for (final o in orders) {
      if (o.status == "Cancelled") continue;

      for (final item in o.items) {
        map[item.name] = (map[item.name] ?? 0) + 1;
      }
    }
    return map;
  }

  List<MapEntry<String, int>> get adminTopProducts {
    final list = adminProductSales.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(5).toList();
  }

  // =====================================================
  // ================= USER ANALYTICS ====================
  // =====================================================

  int get totalOrders => filteredOrders.length;

  double get totalRevenue => filteredOrders
      .where((o) => o.status != "Cancelled")
      .fold(0.0, (sum, o) => sum + o.total);

  Map<String, int> get statusCount {
    final Map<String, int> map = {
      "Placed": 0,
      "Packed": 0,
      "Shipped": 0,
      "Delivered": 0,
      "Cancelled": 0,
    };

    for (final o in filteredOrders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  List<double> get revenueTrend {
    double sum = 0;
    final List<double> points = [];

    for (final o in filteredOrders) {
      if (o.status != "Cancelled") {
        sum += o.total;
        points.add(sum);
      }
    }
    return points;
  }

  // =====================================================
  // ================= ORDER ACTIONS =====================
  // =====================================================

  void updateStatus(String id, String newStatus) {
    final index = orders.indexWhere((o) => o.id == id);
    if (index == -1) return;

    final current = orders[index];

    if (current.status == "Cancelled") {
      Get.snackbar("Invalid Action", "Cancelled orders cannot be updated");
      return;
    }

    orders[index] = current.copyWith(status: newStatus);
  }

  void cancelOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = orders[index];

    if (order.status == "Shipped" || order.status == "Delivered") {
      Get.snackbar("Cannot Cancel", "Order already ${order.status}");
      return;
    }

    // Restore stock
    final productController = Get.find<ProductController>();

    for (final item in order.items) {
      final product =
          productController.products.firstWhereOrNull((p) => p.id == item.id);
      if (product != null) {
        product.stock += 1;
      }
    }

    productController.products.refresh();

    orders[index] = order.copyWith(status: "Cancelled");

    Get.snackbar("Order Cancelled", "Stock restored successfully");
  }

  // =====================================================
  // ================= USER TOP PRODUCTS =================
  // =====================================================

  Map<String, int> get productSales {
    final Map<String, int> map = {};

    for (final o in filteredOrders) {
      if (o.status == "Cancelled") continue;

      for (final item in o.items) {
        map[item.name] = (map[item.name] ?? 0) + 1;
      }
    }
    return map;
  }

  List<MapEntry<String, int>> get topProducts {
    final list = productSales.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(5).toList();
  }
}
