import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/dialogs/menu_dialogs.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/categorias_section.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/mesas_section.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/platillos_section.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GerenteController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.dashboard_customize,
                    size: 28,
                    color: Color(0xFF5D4037),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Menú del Restaurante',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sección de Mesas
              _buildSectionCard(
                context,
                title: 'Mesas',
                icon: Icons.table_bar,
                iconColor: const Color(0xFF6D4C41),
                controller: controller,
                child: MesasSection(controller: controller),
                onAdd: () => showAddMesaDialog(context, controller),
              ),

              // Sección de Platillos
              _buildSectionCard(
                context,
                title: 'Platillos',
                icon: Icons.restaurant_menu,
                iconColor: const Color(0xFF4E342E),
                controller: controller,
                child: PlatillosSection(controller: controller),
                onAdd: () => showAddPlatilloDialog(context, controller),
              ),

              // Sección de Categorías
              _buildSectionCard(
                context,
                title: 'Categorías',
                icon: Icons.category_outlined,
                iconColor: const Color(0xFF3E2723),
                controller: controller,
                child: CategoriasSection(controller: controller),
                onAdd: () => showAddCategoriaDialog(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required void Function() onAdd,
    required GerenteController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
