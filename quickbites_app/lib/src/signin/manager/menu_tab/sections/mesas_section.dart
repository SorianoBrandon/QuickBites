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
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
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
      child: StreamBuilder<List<MesaModel>>(
        stream: controller.getMesasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error al cargar mesas');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final mesas = snapshot.data ?? [];
          if (mesas.isEmpty) {
            return const Text('No hay mesas registradas');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mesas.length,
            itemBuilder: (context, index) {
              final mesa = mesas[index];
              return ListTile(
                title: Text('Mesa: ${mesa.nombre}'),
                subtitle: Text('Capacidad: ${mesa.capacidad}, Ocupada: ${mesa.ocupada ? 'Sí' : 'No'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showEditMesaDialog(context, controller, mesa),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(
                        context,
                        '¿Seguro que deseas eliminar la mesa ${mesa.nombre}?',
                        () => controller.eliminarMesa(mesa.id.toString()),
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