import 'package:flutter/material.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/models/mesa_model.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/dialogs/menu_dialogs.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab/utils/menu_utils.dart';

class MesasSection extends StatelessWidget {
  final GerenteController controller;

  const MesasSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder<List<MesaModel>>(
        stream: controller.getMesasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar mesas',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final mesas = snapshot.data ?? [];
          if (mesas.isEmpty) {
            return const Center(child: Text('No hay mesas registradas'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                mesas.map((mesa) {
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
                            'Mesa: ${mesa.nombre}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.brown[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capacidad: ${mesa.capacidad}, Ocupada: ${mesa.ocupada ? 'Sí' : 'No'}',
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
                                  backgroundColor: Colors.brown[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    () => showEditMesaDialog(
                                      context,
                                      controller,
                                      mesa,
                                    ),
                                child: const Text('Editar'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    () => confirmDelete(
                                      context,
                                      '¿Seguro que deseas eliminar la mesa ${mesa.nombre}?',
                                      () => controller.eliminarMesa(
                                        mesa.id.toString(),
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
