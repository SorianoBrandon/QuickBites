import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/camarero_controller.dart';
import 'package:quickbites_app/src/models/mesa_model.dart';

class SeleccionMesaScreen extends StatelessWidget {
  final Function(String mesaId, String mesaNumber) onMesaSeleccionada;

  const SeleccionMesaScreen({Key? key, required this.onMesaSeleccionada}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final camareroController = Get.find<CamareroController>();
    final establecimiento = camareroController.establecimiento;

    // Check if establecimiento is empty
    if (establecimiento.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar Mesa'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Text(
            'Error: No se ha configurado el establecimiento. Contacte al administrador.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Mesa'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<MesaModel>>(
        stream: camareroController.getMesasDisponiblesStream(establecimiento),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final mesasDisponibles = snapshot.data ?? [];
          if (mesasDisponibles.isEmpty) {
            return const Center(child: Text('No hay mesas disponibles.'));
          }
          print('Mesas disponibles: ${mesasDisponibles.map((m) => {'numero': m.numero, 'ocupada': m.ocupada}).toList()}');

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: mesasDisponibles.length,
            itemBuilder: (context, index) {
              final mesa = mesasDisponibles[index];
              return MesaCard(
                numero: mesa.numero.toString(),
                capacidad: mesa.capacidad.toString(),
                disponible: !mesa.ocupada,
                onTap: () {
                  print('Tocaste la mesa ${mesa.numero}');
                  if (!mesa.ocupada) {
                    onMesaSeleccionada(mesa.id.toString(), mesa.numero.toString());
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
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _mostrarDialogoCrearMesa(context, establecimiento);
        },
      ),
    );
  }

  void _mostrarDialogoCrearMesa(BuildContext context, String establecimiento) {
    final formKey = GlobalKey<FormState>();
    String numero = '';
    String capacidad = '2';

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
                backgroundColor: Colors.orange,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final String mesaId = 'mesa_$numero';
                    final newTable = MesaModel(
                      nombre: 'aaaa',
                      id: mesaId,
                      numero: int.parse(numero),
                      capacidad: int.parse(capacidad),
                      ocupada: false,
                    );

                    await FirebaseFirestore.instance
                        .collection(establecimiento)
                        .doc('mesas')
                        .collection('items')
                        .doc(mesaId)
                        .set(newTable.toJson());

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
    Key? key,
    required this.numero,
    required this.capacidad,
    required this.disponible,
    required this.onTap,
  }) : super(key: key);

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
            ],
          ),
        ),
      ),
    );
  }
}