import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 30), // Espacio para mover el ícono más arriba
              ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 80.0),
                  child: Column(
                    children: [
                      Lottie.asset('assets/NoRoleAnimation.json'),
                      const SizedBox(height: 6.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60), // Más espacio para bajar el botón
              Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Por favor, contacta al administrador para obtener un rol.',
                    style: TextStyle(
                      fontSize: 18, // Tamaño más grande para impacto
                      color: const Color(0xFF6e2c13), // Color del botón para cohesión
                      fontWeight: FontWeight.bold, // Negrita para énfasis
                      letterSpacing: 1.0, // Espaciado para claridad
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 10), // Espacio entre los textos
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6e2c13), width: 1.5), // Borde en lugar de fondo
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Código: ${userController.codigo}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  userController.signOut();
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6e2c13),
                  foregroundColor: const Color(0xFFFFF1D0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}