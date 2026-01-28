import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/banner_controller.dart';
import 'package:image_picker/image_picker.dart'; // optional for picking image

class AdminBannerPage extends StatelessWidget {
  const AdminBannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController bannerCtrl = Get.find<BannerController>();
    final ImagePicker picker = ImagePicker();

    return Scaffold(
      appBar: AppBar(title: const Text("Banner Management")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() {
              if (bannerCtrl.banners.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: Text("No banner uploaded")),
                );
              }

              final currentBanner = bannerCtrl.banners[bannerCtrl.currentIndex.value];

              return Stack(
                children: [
                  Image.file(
                    File(currentBanner),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      width: double.infinity,
                      height: 180,
                      child: const Center(child: Text("Invalid image")),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      "${bannerCtrl.currentIndex.value + 1}/${bannerCtrl.banners.length}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // pick image
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  bannerCtrl.setBanner(image.path); // sets single banner
                  Get.snackbar("Banner", "Banner updated successfully",
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text("Upload Banner"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  bannerCtrl.addBanner(image.path); // adds multiple banners
                  Get.snackbar("Banner", "Banner added successfully",
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add Banner"),
            ),
          ],
        ),
      ),
    );
  }
}