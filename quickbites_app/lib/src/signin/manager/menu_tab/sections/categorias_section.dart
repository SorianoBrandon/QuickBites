import 'package:flutter/material.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/models/categoria_model.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/dialogs/menu_dialogs.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/utils/menu_utils.dart';


class CategoriasSection extends StatelessWidget {
  final GerenteController controller;

  const CategoriasSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
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
      child: StreamBuilder<List<CategoriaModel>>(
        stream: controller.getCategoriasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error al cargar categorías');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final categorias = snapshot.data ?? [];
          if (categorias.isEmpty) {
            return const Text('No hay categorías registradas');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return ListTile(
                title: Text(categoria.nombre),
                subtitle: Text('Subcategorías: ${categoria.subcategorias.join(', ')}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showEditCategoriaDialog(context, controller, categoria),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(
                        context,
                        '¿Seguro que deseas eliminar la categoría ${categoria.nombre}?',
                        () => controller.eliminarCategoria(categoria.nombre),
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