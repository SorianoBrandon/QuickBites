import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/dialogs/menu_dialogs.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/categorias_section.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/mesas_section.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/sections/platillos_section.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/utils/menu_utils.dart';


class MenuTab extends StatelessWidget {
  final GerenteController controller = Get.find<GerenteController>();

  MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Menú'),
        backgroundColor: Colors.blue[100]!,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Mesas
            Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(
                    'Mesas',
                    icon: Icons.table_bar,
                    backgroundColor: Colors.blue[100]!,
                    textColor: Colors.blue[900]!,
                  ),
                  MesasSection(controller: controller),
                  const SizedBox(height: 12),
                  buildAddButton(
                    context,
                    'Agregar Mesa',
                    () => showAddMesaDialog(context, controller),
                    buttonColor: Colors.blue[600]!,
                  ),
                ],
              ),
            ),

            // Sección de Platillos
            Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(
                    'Platillos',
                    icon: Icons.restaurant,
                    backgroundColor: Colors.green[100]!,
                    textColor: Colors.green[900]!,
                  ),
                  PlatillosSection(controller: controller),
                  const SizedBox(height: 12),
                  buildAddButton(
                    context,
                    'Agregar Platillo',
                    () => showAddPlatilloDialog(context, controller),
                    buttonColor: Colors.green[600]!,
                  ),
                ],
              ),
            ),

            // Sección de Categorías
            Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(
                    'Categorías',
                    icon: Icons.category,
                    backgroundColor: Colors.orange[100]!,
                    textColor: Colors.orange[900]!,
                  ),
                  CategoriasSection(controller: controller),
                  const SizedBox(height: 12),
                  buildAddButton(
                    context,
                    'Agregar Categoría',
                    () => showAddCategoriaDialog(context, controller),
                    buttonColor: Colors.orange[600]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}