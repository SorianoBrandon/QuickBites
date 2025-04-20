import 'package:flutter/material.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/models/platillo_model.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/dialogs/menu_dialogs.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/utils/menu_utils.dart';


class PlatillosSection extends StatelessWidget {
  final GerenteController controller;

  const PlatillosSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder<List<PlatilloModel>>(
        stream: controller.getPlatillosStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error al cargar platillos');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final platillos = snapshot.data ?? [];
          if (platillos.isEmpty) {
            return const Text('No hay platillos registrados');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: platillos.length,
            itemBuilder: (context, index) {
              final platillo = platillos[index];
              return ListTile(
                title: Text(platillo.nombre),
                subtitle: Text('Precio: \$${platillo.precio} | Categoría: ${platillo.categoria} | Subcategoría: ${platillo.subcategoria}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showEditPlatilloDialog(context, controller, platillo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(
                        context,
                        '¿Seguro que deseas eliminar el platillo ${platillo.nombre}?',
                        () => controller.eliminarPlatillo(platillo.id.toString()),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}