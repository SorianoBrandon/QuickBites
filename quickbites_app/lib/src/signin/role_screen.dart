import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:get/get.dart';

class ManagerScreen extends StatelessWidget {
  ManagerScreen({super.key});

  final userController = Get.find<UserController>();

  // Referencia a la colección de usuarios en Firebase.
  final CollectionReference usuariosRef = FirebaseFirestore.instance.collection(
    'usuarios',
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text("${userController.nombre} ${userController.apellido}"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Usuario"),
              Tab(text: "Local"),
              Tab(text: "Menú"),
              Tab(text: "Cocina"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.output_rounded),
                title: const Text('Cerrar Sesión'),
                onTap: () {
                  userController.signOut();
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EmpleadoSearchWidget(usuariosRef: usuariosRef),
            EmpleadoListWidget(establecimiento: userController.establecimiento),
            const Center(child: Text("Contenido del Menú")),
            const Center(child: Text("Contenido de Cocina")),
          ],
        ),
      ),
    );
  }
}

//---------------------------------------------------------------------------------------
class EmpleadoListWidget extends StatelessWidget {
  EmpleadoListWidget({Key? key, required this.establecimiento})
    : super(key: key);

  final String establecimiento;
  final CollectionReference _usuariosRef = FirebaseFirestore.instance
      .collection('usuarios');

  /// Elimina un empleado de Firestore
  Future<void> _softDeleteEmpleado(String docId) async {
    await _usuariosRef.doc(docId).update({'rol': '', 'establecimiento': ''});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _usuariosRef
              .where('establecimiento', isEqualTo: establecimiento)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text('No hay empleados en $establecimiento'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? '';
            final apellido = data['apellido'] ?? '';
            final rol = data['rol'] ?? 'N/A';

            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${nombre.isNotEmpty ? nombre[0] : ""}${apellido.isNotEmpty ? apellido[0] : ""}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  '$nombre $apellido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rol: $rol', style: TextStyle(fontSize: 11.0)),
                    Text(
                      'Local: $establecimiento',
                      style: TextStyle(fontSize: 11.0),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text('Eliminar empleado'),
                            content: Text(
                              '¿Seguro que deseas eliminar a $nombre $apellido?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await _softDeleteEmpleado(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            '\${nombre} \${apellido} ha sido marcado como eliminado',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

//---------------------------------------------------------------------------------------
class EmpleadoSearchWidget extends StatefulWidget {
  const EmpleadoSearchWidget({super.key, required this.usuariosRef});
  final CollectionReference usuariosRef;

  @override
  _EmpleadoSearchWidgetState createState() => _EmpleadoSearchWidgetState();
}

class _EmpleadoSearchWidgetState extends State<EmpleadoSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _searchResult;

  // Ejecuta la búsqueda sobre el campo "codigo"
  void _performSearch() {
    final code = _searchController.text.trim().toUpperCase();
    if (code.isNotEmpty) {
      setState(() {
        _searchResult =
            widget.usuariosRef.where('codigo', isEqualTo: code).get();
      });
    }
  }

  // Restablece el estado de la búsqueda
  void _resetSearch() {
    setState(() {
      _searchResult = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función que muestra el modal para la edición de rol y establecimiento.
  void _showEditModal(DocumentSnapshot empleado) {
    final String currentRol = empleado.get('rol') ?? '';
    final String currentEstablecimiento = empleado.get('establecimiento') ?? '';
    String selectedRol = currentRol.isNotEmpty ? currentRol : 'Cocina';
    final TextEditingController establecimientoController =
        TextEditingController(text: currentEstablecimiento);

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
                        'Editar Información',
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
                      items: const [
                        DropdownMenuItem(
                          value: 'Gerente',
                          child: Text('Gerente'),
                        ),
                        DropdownMenuItem(
                          value: 'Mesero',
                          child: Text('Mesero'),
                        ),
                        DropdownMenuItem(
                          value: 'Cocina',
                          child: Text('Cocina'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedRol = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: establecimientoController,
                      decoration: const InputDecoration(
                        labelText: 'Establecimiento',
                        border: OutlineInputBorder(),
                      ),
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
                          final nuevoEstablecimiento =
                              establecimientoController.text.trim();

                          // Verificar si el establecimiento existe en la colección "Pizza Hut"
                          final snap =
                              await FirebaseFirestore.instance
                                  .collection('Pizza Hut')
                                  .doc(nuevoEstablecimiento)
                                  .get();

                          if (!snap.exists) {
                            setModalState(() {
                              errorMessage = 'El establecimiento no existe';
                            });
                            return;
                          } else {
                            setModalState(() {
                              errorMessage = null;
                            });
                          }

                          try {
                            // Actualizar el documento del empleado
                            await empleado.reference.update({
                              'rol': selectedRol,
                              'establecimiento': nuevoEstablecimiento,
                            });

                            // Obtener el nombre del empleado
                            // final nombreEmpleado = empleado.get('nombre') ?? 'Sin nombre';

                            // Agregar el empleado a la colección "personal" de la sucursal
                            // await FirebaseFirestore.instance
                            //     .collection('Pizza Hut')
                            //     .doc(nuevoEstablecimiento)
                            //     .collection('personal')
                            //     .add({
                            //   'nombre': nombreEmpleado,
                            //   'rol': selectedRol,
                            // });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  'Información actualizada y empleado agregado a la sucursal',
                                ),
                              ),
                            );

                            Navigator.of(modalContext).pop();
                            _resetSearch(); // Limpiar la búsqueda
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

  // Construye la Card que muestra la información del empleado.
  Widget _buildEmpleadoCard(DocumentSnapshot empleado) {
    final nombre = empleado.get('nombre') ?? 'Sin nombre';
    final apellido = empleado.get('apellido') ?? 'Sin apellido';
    final rol = empleado.get('rol') ?? ' N / A';
    final codigo = empleado.get('codigo') ?? 'Sin código';
    final establecimiento = empleado.get('establecimiento') ?? ' N / A ';

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
                "Codigo: $codigo",
                style: const TextStyle(fontSize: 10, color: Colors.green),
              ),
              Text(
                "Establecimiento: $establecimiento",
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
                      return const Center(
                        child: Text(
                          'Ha ocurrido un error',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Usuario no existe',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return _buildEmpleadoCard(docs.first);
                  },
                ),
          ],
        ),
      ),
    );
  }
}
