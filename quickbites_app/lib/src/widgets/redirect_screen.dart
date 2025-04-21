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
        if (rol == 'Gerente') {
          context.goNamed('manager');
        } else if (rol == 'Mesero'){
          context.goNamed('waiter');
        }else if (rol == 'Cocinero'){
          context.goNamed('kitchen');
        }
        else 
        context.goNamed('no-role');
      } else {
        context.goNamed('login');
      }
    });

    // Pantalla de espera mientras se redirige
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
