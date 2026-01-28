import 'package:get/get.dart';

class UserNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  // ⭐ NEW: open Orders tab directly
  void goToOrders() {
    currentIndex.value = 2;
  }
}
