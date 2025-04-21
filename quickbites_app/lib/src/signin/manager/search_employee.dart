import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class SearchEmployee extends StatefulWidget {
  final CollectionReference usuariosRef;

  SearchEmployee({required this.usuariosRef});

  @override
  _SearchEmployeeState createState() => _SearchEmployeeState();
}

class _SearchEmployeeState extends State<SearchEmployee> {
  final TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _searchResult;

  void _performSearch() {
    final code = _searchController.text.trim().toUpperCase();
    if (code.isNotEmpty) {
      setState(() {
        _searchResult =
            widget.usuariosRef.where('codigo', isEqualTo: code).get();
      });
    }
  }

  /*void _resetSearch() {
    setState(() {
      _searchResult = null;
      _searchController.clear();
    });
  }*/

  void _showEditModal(DocumentSnapshot empleado) {
    final String currentRol = empleado.get('rol') ?? '';
    final List<String> roles = ['Gerente', 'Mesero', 'Cocina'];
    String selectedRol =
        currentRol.isNotEmpty && roles.contains(currentRol)
            ? currentRol
            : 'Cocina';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Editar Rol',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rol',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedRol,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedRol = value;
                          });
                        }
                      },
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "$errorMessage",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final establecimientoGerente =
                                Get.find<UserController>().establecimiento;
                            await empleado.reference.update({
                              'rol': selectedRol,
                              'establecimiento': establecimientoGerente,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Rol actualizado correctamente'),
                              ),
                            );
                            Navigator.of(modalContext).pop();
                            _performSearch(); // Volver a buscar para reflejar el cambio
                          } catch (e) {
                            setModalState(() {
                              errorMessage = 'Error: $e';
                            });
                          }
                        },
                        child: const Text('Actualizar'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmpleadoCard(DocumentSnapshot empleado) {
    final data = empleado.data() as Map<String, dynamic>;
    final nombre = data['nombre'] ?? 'Sin nombre';
    final apellido = data['apellido'] ?? 'Sin apellido';
    final rol = data['rol'] ?? 'N/A';
    final codigo = data['codigo'] ?? 'Sin código';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 3.0,
          horizontal: 3.0,
        ),
        leading: const Icon(Icons.person, size: 40, color: Colors.blueAccent),
        title: Text(
          "$nombre $apellido",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Puesto: $rol",
                style: const TextStyle(fontSize: 10, color: Colors.green),
              ),
              Text(
                "Código: $codigo",
                style: const TextStyle(fontSize: 10, color: Colors.green),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.green),
          onPressed: () {
            _showEditModal(empleado);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por código',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            _searchResult == null
                ? const Center(
                  child: Text('Ingrese un código y presione Buscar'),
                )
                : FutureBuilder<QuerySnapshot>(
                  future: _searchResult,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Ha ocurrido un error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('Usuario no existe'));
                    }
                    final empleado = docs.first;
                    final data = empleado.data() as Map<String, dynamic>;
                    final establecimiento = data['establecimiento'] ?? '';

                    if (establecimiento.isNotEmpty) {
                      return const Center(
                        child: Text('Usuario ya se encuentra asignado'),
                      );
                    } else {
                      return _buildEmpleadoCard(empleado);
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}
