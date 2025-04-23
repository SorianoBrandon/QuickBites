import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class RedirectScreen extends StatelessWidget {
  RedirectScreen({super.key});

  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    // Asegura que la redirección se realice después del build
    Future.microtask(() {
      if (userController.isLoggedIn && userController.userData.value != null) {
        final rol = userController.rol;
        if (rol == 'Gerente'.toUpperCase()) {
          context.goNamed('manager'.toUpperCase());
        } else if (rol == 'Mesero'.toUpperCase()) {
          context.goNamed('waiter'.toUpperCase());
        } else if (rol == 'Cocina'.toUpperCase()) {
          context.goNamed('kitchen'.toUpperCase());
        } else
          context.goNamed('no-role'.toUpperCase());
      } else {
        context.goNamed('login'.toUpperCase());
      }
    });
    // Pantalla de espera mientras se redirige
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
