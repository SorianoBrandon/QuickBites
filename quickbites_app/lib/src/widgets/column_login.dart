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
            onPressed: () {
              contactanos(context);
            },
            child: Text(
              '¿Tienes un Restaurante?',
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
                if (logController.isEstablecimiento()) {
                  context.go('/');
                  logController.clearFields();
                } else {
                  userController.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'El Establecimiento debe ser Especificado.',
                      ),
                    ),
                  );
                }
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

void contactanos(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Color(0xFFFFF1D0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant, color: Colors.redAccent, size: 40),
              SizedBox(height: 16),
              Text(
                '¡Que tu restaurante forme parte de nuestro equipo en QuickBites!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Mándanos un correo con la información de tu restaurante solicitando formar parte de nuestro equipo a:',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              SelectableText(
                'quickbitesproject@gmail.com',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B2C1B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
