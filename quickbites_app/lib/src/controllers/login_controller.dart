import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  final UserController userController = Get.find<UserController>();
  final isLogin = true.obs;
  final isAnimating = false.obs;

  var confirmPasswordTextColor = Rxn<Color>();
  late final AnimationController controller;
  late final Animation<double> heightFactor;

  @override
  void onInit() {
    super.onInit();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1;

    heightFactor = controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  Future<void> toggleForm() async {
    if (isAnimating.value) return;
    isAnimating.value = true;
    await controller.reverse();
    isLogin.value = !isLogin.value;
    await Future.delayed(const Duration(milliseconds: 30));
    await controller.forward();
    isAnimating.value = false;
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  final Map<String, TextEditingController> controllers = {
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'name': TextEditingController(),
    'lastName': TextEditingController(),
    'address': TextEditingController(),
    'phone': TextEditingController(),
    'establecimiento': TextEditingController(),
  };

  void validatePasswords(String _) {
    if (controllers['password']!.text != controllers['confirmPassword']!.text) {
      confirmPasswordTextColor.value = Colors.red;
    } else {
      confirmPasswordTextColor.value = null;
    }
  }

  void clearFields() {
    for (var controller in controllers.values) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    for (var control in controllers.values) {
      control.dispose();
    }
    super.dispose();
  }

  bool isEstablecimiento() {
    if (controllers['establecimiento']!.text.trim() !=
        userController.establecimiento) {
      return false;
    }
    return true;
  }
}
