import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/widgets/text_field_login.dart';
import 'package:quickbites_app/src/controllers/login_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class ColumnLogin extends StatelessWidget {
  ColumnLogin({super.key});

  final logController = Get.find<LoginController>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.orange[50],
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Establecimiento
        Center(
          child: textField(
            controler: logController.controllers['establecimiento']!,
            unseenText: false,
            boardType: TextInputType.text,
            texto: 'Establecimiento',
            textColor: const Color(0xFF6e2c13),
          ),
        ),
        const SizedBox(height: 20),

        // Email
        textField(
          controler: logController.controllers['email']!,
          texto: 'Correo Electrónico',
          unseenText: false,
          boardType: TextInputType.emailAddress,
          icono: Icons.email,
        ),
        const SizedBox(height: 20),

        // Contraseña
        textField(
          controler: logController.controllers['password']!,
          texto: 'Contraseña',
          unseenText: true,
          boardType: TextInputType.visiblePassword,
          icono: Icons.lock_person_rounded,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: () async {
            try {
              bool logIn = await userController.loginWithEmail(
                logController.controllers['email']!.text.trim(),
                logController.controllers['password']!.text.trim(),
              );
              if (logIn) {
                context.go('/');
                logController.clearFields();
              }
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf03c0f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 10),
          ),
          child: Text(
            '¡Vamos!',
            style: TextStyle(
              color: Colors.grey[100],
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
