import 'package:flutter/material.dart';
import 'package:quickbites_app/screens/waiter/SeleccionMesaScreen.dart';
import 'package:quickbites_app/screens/waiter/menu_waiter.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/camarero_controller.dart';

class HomePageWaiter extends StatelessWidget {
  const HomePageWaiter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializando el controlador de camarero con GetX
    final camareroController = Get.put(CamareroController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesero'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Usando el stream del controlador
        stream: camareroController.getOccupiedTablesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final occupiedTables = snapshot.data ?? [];
          
          // Ordenando las mesas por número
          occupiedTables.sort((a, b) => (a['number'] as num).compareTo(b['number'] as num));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de mesas ocupadas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mesas Ocupadas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: ${occupiedTables.length} mesas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de mesas ocupadas
                Expanded(
                  child: occupiedTables.isEmpty
                      ? const Center(child: Text('No hay mesas ocupadas actualmente.'))
                      : ListView.builder(
                          itemCount: occupiedTables.length,
                          itemBuilder: (context, index) {
                            final table = occupiedTables[index];
                            
                            // Usar el controlador para formatear la hora (lo añadi al camarero_controller.dart)
                            String horaOcupada = "Ocupada";
                            if (table['occupiedAt'] != null) {
                              horaOcupada = camareroController.formatOccupiedTime(table['occupiedAt']);
                            }
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.orange.shade200, width: 1),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Navegar a la pantalla de menú
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MenuScreen(
                                        mesaId: table['id'],
                                        mesaNumber: table['number'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Círculo con número de mesa
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          table['number'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Información de la mesa
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mesa No. ${table['number'].toString()}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              horaOcupada,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Etiqueta de OCUPADA y flecha
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'OCUPADA',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                const SizedBox(height: 16),
                // Botón para seleccionar nueva mesa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeleccionMesaScreen(
                            onMesaSeleccionada: (mesaId, mesaNumber) async {
                              // Usar el controlador para seleccionar la mesa
                              await camareroController.seleccionarMesa(mesaId, mesaNumber);
                              
                              Navigator.pop(context);

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
                      'SELECCIONAR MESA NUEVA',
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