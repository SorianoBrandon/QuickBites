import 'package:flutter/material.dart';
import 'package:quickbites_app/src/models/empleados_model.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:quickbites_app/src/controllers/gerente_controller.dart';

class LocalTab extends StatelessWidget {
  final String establecimiento;
  LocalTab({required this.establecimiento});

  final TextEditingController searchController = TextEditingController();
  final RxList<EmpleadoModel> empleadosFiltrados = <EmpleadoModel>[].obs;
  final RxList<EmpleadoModel> empleadosOriginales = <EmpleadoModel>[].obs;

  void _filtrarEmpleados(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty || lowerQuery.length < 4) {
      empleadosFiltrados.assignAll(empleadosOriginales);
    } else if (lowerQuery.length > 4) {
      empleadosFiltrados.assignAll(
        empleadosOriginales.where((empleado) {
          final nombre = empleado.nombre.toLowerCase();
          final apellido = empleado.apellido.toLowerCase();
          return nombre.contains(lowerQuery) || apellido.contains(lowerQuery);
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GerenteController controller = Get.find<GerenteController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: _filtrarEmpleados,
              decoration: InputDecoration(
                hintText: 'Nombre Apellido',
                prefixIcon: Icon(Icons.search, color: Colors.brown[300]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EmpleadoModel>>(
              stream: controller.getEmpleadosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar empleados.'),
                  );
                }

                final empleados = snapshot.data ?? [];

                // Actualizar ambas listas cuando llega un nuevo snapshot
                empleadosOriginales.assignAll(empleados);
                _filtrarEmpleados(searchController.text); // reaplicar filtro

                return Obx(() {
                  if (empleadosFiltrados.isEmpty) {
                    return Center(
                      child: Text(
                        'Ups... Sin coincidencias.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: empleadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final empleado = empleadosFiltrados[index];
                      final nombre = empleado.nombre;
                      final apellido = empleado.apellido;
                      final rol = empleado.rol;

                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F3EF),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                60,
                                12,
                              ),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.brown[300],
                                child: Text(
                                  '${nombre.isNotEmpty ? nombre[0] : ""}${apellido.isNotEmpty ? apellido[0] : ""}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '$nombre $apellido',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Rol: $rol\nLocal: $establecimiento',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Eliminar empleado'),
                                        content: Text(
                                          '¿Seguro que deseas eliminar a $nombre $apellido?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Get.back(result: false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Get.back(result: true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  await controller.softDeleteEmpleado(
                                    empleado.id,
                                  );
                                  await controller.updateEmpleadosLocalmente();
                                }
                              },
                              child: ClipPath(
                                clipper: _CornerClipper(),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.9),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 10),
        child: GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();

            // Esperar una duración fija razonable (suficiente para que el teclado se cierre)
            await Future.delayed(const Duration(milliseconds: 300));

            mostrarModalAsignarEmpleado();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.brown.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.12),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF5B2C1B),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Clipper para efecto de esquina doblada
class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 16);
    path.quadraticBezierTo(0, size.height, 16, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

void mostrarModalAsignarEmpleado() {
  final TextEditingController codigoController = TextEditingController();
  final RxString rolSeleccionado = 'Caja'.obs;
  final RxnString errorMensaje = RxnString();
  final RxBool cargando = false.obs;

  final List<String> roles = ['Caja', 'Mesero', 'Cocina'];

  Get.bottomSheet(
    Obx(
      () => GestureDetector(
        onTap:
            () =>
                FocusScope.of(
                  Get.context!,
                ).unfocus(), // Cierra teclado al tocar fuera
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Asignar nuevo empleado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E3E3E),
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: codigoController,
                        decoration: InputDecoration(
                          labelText: 'Código del empleado',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.brown),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: rolSeleccionado.value,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            roles
                                .map(
                                  (rol) => DropdownMenuItem(
                                    value: rol,
                                    child: Text(rol),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          FocusScope.of(
                            Get.context!,
                          ).unfocus(); // Evita cierre del teclado incorrecto
                          if (val != null) rolSeleccionado.value = val;
                        },
                      ),

                      if (errorMensaje.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            errorMensaje.value!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                foregroundColor: Colors.brown.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  cargando.value
                                      ? null
                                      : () async {
                                        final codigo =
                                            codigoController.text.trim();
                                        if (codigo.isEmpty) {
                                          errorMensaje.value =
                                              'El código no puede estar vacío';
                                          return;
                                        }

                                        errorMensaje.value = null;
                                        cargando.value = true;

                                        final error =
                                            await Get.find<GerenteController>()
                                                .asignarEmpleadoPorCodigo(
                                                  codigo: codigo,
                                                  rol: rolSeleccionado.value,
                                                );

                                        cargando.value = false;

                                        if (error != null) {
                                          errorMensaje.value = error;
                                        } else {
                                          Get.back();
                                          Get.snackbar(
                                            'Éxito',
                                            'Empleado asignado correctamente',
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child:
                                  cargando.value
                                      ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text('Agregar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
