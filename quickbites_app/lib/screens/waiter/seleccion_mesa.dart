import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbites_app/screens/waiter/menu_waiter.dart';
import 'package:quickbites_app/src/widgets/mesa_card.dart';

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
              childAspectRatio: 0.9,
            ),
            itemCount: mesas.length,
            itemBuilder: (context, index) {
            final mesa = mesas[index].data() as Map<String, dynamic>;
            final isDisponible = mesa['status'] == "available" ? true : false;
  
           return MesaCard(
            numero: mesa['number'].toString(),
            capacidad: mesa['capacidad']?.toString() ?? '4',
            disponible: isDisponible,
            onTap: () async {
              if (isDisponible) {
                // Primero marcamos la mesa como ocupada
                print("NOOOOOOOOOOOOO pasoooooooooooooooooooo");
                await onMesaSeleccionada(mesas[index].id, mesa['number']);
                print("pasoooooooooooooooooooo");                
                // // Pequeña pausa para permitir que Firestore se actualice
                // await Future.delayed(const Duration(milliseconds: 500));
                
                // Luego navegamos al menú
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(
                      mesaId: mesas[index].id,
                      mesaNumber: mesa['number'].toString(),
                    ),
                  ),
                );
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
    );
  }
}
