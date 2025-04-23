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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder<List<CategoriaModel>>(
        stream: controller.getCategoriasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar categorías',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final categorias = snapshot.data ?? [];
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorías registradas'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                categorias.map((categoria) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3EF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.brown[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subcategorías: ${categoria.subcategorias.join(', ')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.brown[600], // Nuevo color
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    () => showEditCategoriaDialog(
                                      context,
                                      controller,
                                      categoria,
                                    ),
                                child: const Text('Editar'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red[600], // Nuevo color
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    () => confirmDelete(
                                      context,
                                      '¿Seguro que deseas eliminar la categoría ${categoria.nombre}?',
                                      () => controller.eliminarCategoria(
                                        categoria.nombre,
                                      ),
                                    ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
