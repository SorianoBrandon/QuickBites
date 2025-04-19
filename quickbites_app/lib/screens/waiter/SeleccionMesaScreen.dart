import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeleccionMesaScreen extends StatelessWidget {
  final Function(String mesaId, String mesaNumber) onMesaSeleccionada;

  const SeleccionMesaScreen({super.key, required this.onMesaSeleccionada});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Mesa'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Cambiado: Ruta corregida para coincidir con el controlador
        stream: FirebaseFirestore.instance
            .collection('Restaurante')
            .doc('mesas')
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las mesas'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mesas = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Ajustado para mejor proporción
            ),
            itemCount: mesas.length,
            itemBuilder: (context, index) {
              final mesa = mesas[index].data() as Map<String, dynamic>;
              final isDisponible = mesa['status'] == null || 
                                 mesa['status'] == 'available' || 
                                 mesa['status'] == '';
              
              return MesaCard(
                numero: mesa['number'].toString(),
                capacidad: mesa['capacidad']?.toString() ?? '2',
                disponible: isDisponible,
                onTap: () {
                  if (isDisponible) {
                    onMesaSeleccionada(mesas[index].id, mesa['number'].toString());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Esta mesa no está disponible'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _mostrarDialogoCrearMesa(context);
        },
      ),
    );
  }

  void _mostrarDialogoCrearMesa(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String numero = '';
    String capacidad = '2';
    
    // Nombre del establecimiento consistente con GerenteController
    final establecimiento = 'Restaurante';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Mesa'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Número de mesa',
                    hintText: 'Ej: 1, 2, 3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un número para la mesa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    numero = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Capacidad (personas)',
                    hintText: 'Ej: 2, 4, 6',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '2',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la capacidad';
                    }
                    final parsedValue = int.tryParse(value);
                    if (parsedValue == null || parsedValue <= 0) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    capacidad = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final String mesaId = 'mesa_$numero';
                    
                    final newTable = {
                      'id': mesaId,
                      'nombre': numero,
                      'number': numero,
                      'capacidad': int.tryParse(capacidad) ?? 2,
                      'ocupada': false,
                      'status': 'available'
                    };
                    
                    // Ruta corregida para coincidir con el controlador
                    await FirebaseFirestore.instance
                      .collection(establecimiento)
                      .doc('mesas')
                      .collection('items')
                      .doc(mesaId)
                      .set(newTable);
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mesa agregada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al agregar mesa: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MesaCard extends StatelessWidget {
  final String numero;
  final String capacidad;
  final bool disponible;
  final VoidCallback onTap;

  const MesaCard({
    super.key,
    required this.numero,
    required this.capacidad,
    required this.disponible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: disponible ? Colors.white : Colors.grey[300],
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disponible ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesa $numero',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: disponible ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capacidad: $capacidad personas',
                style: TextStyle(
                  fontSize: 16,
                  color: disponible ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: disponible ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: disponible ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  disponible ? 'DISPONIBLE' : 'OCUPADA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: disponible ? Colors.green[800] : Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ),
              if (!disponible)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'RESERVADO',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}