import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:get/get.dart';

class ManagerScreen extends StatelessWidget {
  ManagerScreen({super.key});

  final userController = Get.find<UserController>();
  // Función para estructurar los ítems del Drawer
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.white70,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ), // Menos espacio entre los ítems
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.3), // Efecto al presionar
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15), // Fondo suave
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 18.0,
          ), // Reducido el padding lateral
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(GerenteController());
    final gerController = Get.find<GerenteController>();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 45,
        leading: Builder(
          builder:
              (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(
                  Icons.menu_rounded,
                  size: 35,
                  color: Colors.grey[300],
                ),
              ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.0)),
        ),
        backgroundColor: Color(0xFF5B2C1B),
        title: Text(
          '${userController.establecimiento}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            wordSpacing: -3,
            color: const Color.fromARGB(255, 224, 224, 224),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5B2C1B), Color(0xFF3E1E14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 60),
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Text(
                  '${userController.nombre[0]}${userController.apellido[0]}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${userController.nombre} ${userController.apellido}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                'Código: ${userController.codigo}',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                userController.establecimiento,
                style: TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userController.email,
                style: TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userController.rol.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(
                color: Colors.white.withValues(alpha: 0.2),
                thickness: 1,
                height: 0,
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      Icons.people_alt_rounded,
                      'Integrantes',
                      () {
                        gerController.selectedView.value = 0;
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(Icons.list_alt_rounded, 'Menú', () {
                      gerController.selectedView.value = 1;
                      Navigator.pop(context);
                    }),
                    _buildDrawerItem(Icons.output_rounded, 'Cerrar Sesión', () {
                      userController.signOut();
                      context.go('/login');
                    }, color: Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() => gerController.views[gerController.selectedView.value]),
    );
  }
}
