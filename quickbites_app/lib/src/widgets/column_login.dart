import 'package:flutter/material.dart';
import 'package:quickbites_app/src/auth/auth_register.dart';
import 'package:quickbites_app/src/signin/role_loading_screen.dart';
import 'package:quickbites_app/src/widgets/text_field_login.dart';

class ColumnLogin extends StatelessWidget {
  ColumnLogin({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController establecimientoController =
      TextEditingController();

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
            controler: establecimientoController,
            texto: 'Establecimiento',
          ),
        ),
        const SizedBox(height: 20),

        // Email
        textField(
          controler: emailController,
          texto: 'Correo Electrónico',
          icono: Icons.email,
        ),
        const SizedBox(height: 20),

        // Contraseña
        textField(
          controler: passwordController,
          texto: 'Contraseña',
          icono: Icons.lock_person_rounded,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
            },
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Botón Entrar
        ElevatedButton(
          onPressed: () async {

            try {
              // 1) Autenticarse
              await AuthService().loginWithEmailAndPassword(
                emailController.text.trim(),
                passwordController.text,
                context,
              );
              // 2) Verificar rol y navegar
              await RoleLoadingScreen().checkUserRole(contexto: context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
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
