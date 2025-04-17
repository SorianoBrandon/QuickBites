import 'package:flutter/material.dart';
import 'package:quickbites_app/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:quickbites_app/screens/waiter/menu_waiter.dart';
import 'package:quickbites_app/screens/waiter/SeleccionMesaScreen.dart';


class HomePageWaiter extends StatelessWidget {
  const HomePageWaiter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesero'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tus Órdenes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: orders.isEmpty
                      ? const Center(child: Text('No hay órdenes disponibles.'))
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final Timestamp createdAt = order['createdAt'];
                            final String horaFormateada = DateFormat.jm().format(createdAt.toDate());
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Text(order['mesa'].toString()),
                                ),
                                title: Text('Mesa No. ${order['mesa'].toString()}'),
                                subtitle: Text('Inicio: $horaFormateada'),
                                trailing: Text(order['total'].toString()),
                                onTap: () {
                                  // acción al tocar la orden
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                // Botón para seleccionar mesa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeleccionMesaScreen(
                            onMesaSeleccionada: (mesaId, mesaNumber) {
                              Navigator.pop(context); // Cierra la pantalla de selección de mesa

                              // Ahora redirige al menú
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuScreen(
                                    mesaId: mesaId,
                                    mesaNumber: mesaNumber,
                                  ),
                                ),
                              );
                            },

                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.table_restaurant, color: Colors.white),
                    label: const Text(
                      'SELECCIONAR MESA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}