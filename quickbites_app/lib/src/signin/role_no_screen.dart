import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class NoRoleScreen extends StatefulWidget {
  const NoRoleScreen({super.key});

  @override
  NoRoleScreenState createState() => NoRoleScreenState();
}

class NoRoleScreenState extends State<NoRoleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1D0), Color(0xFF6e2c13)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 30,
              ), // Espacio para mover el ícono más arriba

              const SizedBox(height: 30),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'Por favor, contacta al administrador para obtener un rol.',
                        // Agregar el CODIGO del usuario ********
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text('Codigo: ${userController.codigo}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60), // Más espacio para bajar el botón
              ElevatedButton(
                onPressed: () {
                  userController.signOut();
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6e2c13),
                  foregroundColor: Color(0xFFFFF1D0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ), // Botón más pequeño
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 16), // Texto más pequeño
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
