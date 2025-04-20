import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalTab extends StatelessWidget {
  final String establecimiento;
  final CollectionReference usuariosRef;

  LocalTab({required this.establecimiento, required this.usuariosRef});

  Future<void> _softDeleteEmpleado(String docId) async {
    await usuariosRef.doc(docId).update({'rol': '', 'establecimiento': ''});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: usuariosRef.where('establecimiento', isEqualTo: establecimiento).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${nombre.isNotEmpty ? nombre[0] : ""}${apellido.isNotEmpty ? apellido[0] : ""}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('$nombre $apellido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rol: $rol', style: TextStyle(fontSize: 11.0)),
                    Text('Local: $establecimiento', style: TextStyle(fontSize: 11.0)),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Eliminar empleado'),
                        content: Text('¿Seguro que deseas eliminar a $nombre $apellido?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _softDeleteEmpleado(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('$nombre $apellido ha sido marcado como eliminado'),
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