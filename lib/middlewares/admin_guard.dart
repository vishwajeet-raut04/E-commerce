import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/session_controller.dart';

class AdminGuard extends GetMiddleware {
  final SessionController session = Get.find<SessionController>();

  @override
  RouteSettings? redirect(String? route) {
    if (!session.isAdmin.value) {
      return const RouteSettings(name: "/login");
    }
    return null;
  }
}
