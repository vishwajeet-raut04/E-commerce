import 'package:get/get.dart';

class BannerController extends GetxController {
  RxList<String> banners = <String>[
    "assets/banners/banner1.jpg",
    "assets/banners/banner2.jpg",
    "assets/banners/banner3.jpg",
  ].obs;

  RxInt currentIndex = 0.obs;

  // change current index for slider
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // load from API or Firebase
  void loadBannersFromApi(List<String> apiBanners) {
    banners.value = apiBanners;
  }

  // =================== NEW METHODS ===================
  // Replace existing banners (used by admin)
  void setBanner(String path) {
    banners.clear();
    banners.add(path);
  }

  // Add additional banner without removing old ones
  void addBanner(String path) {
    banners.add(path);
  }
}