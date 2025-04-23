import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/cocina_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:quickbites_app/src/models/pedido_model.dart';

class HomePageKitchen extends StatefulWidget {
  @override
  _HomePageKitchenState createState() => _HomePageKitchenState();
}

class _HomePageKitchenState extends State<HomePageKitchen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CocinaController _cocinaController = Get.put(CocinaController());
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocina', style: TextStyle(color: Color(0xFF6e2c13))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF6e2c13),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF6e2c13),
          tabs: [Tab(text: 'Pendientes'), Tab(text: 'Listos')],
        ),
        actions: [
          IconButton(
            onPressed: (){
              userController.signOut();
              context.go("/login");
            }, 
            icon: Icon(Icons.logout, color: Color(0xFF6e2c13),)
          ),
          SizedBox(width: 15.0,)
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pendientes Tab
          _buildOrdersList('pendiente'),
          // Listos Tab
          _buildOrdersList('preparado'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String statusFilter) {
    return Obx(() {
      // Usar el valor observable de establecimiento
      final establecimientoValue = _cocinaController.establecimiento.value;

      // Verificación para evitar problemas con establecimiento vacío
      if (establecimientoValue.isEmpty) {
        return Center(
          child: Text('Error: No se ha configurado el establecimiento'),
        );
      }

      final Stream<List<PedidoModel>> pedidosStream =
          statusFilter == 'pendiente'
              ? _cocinaController.getPedidosPendientesStream(
                establecimientoValue,
              )
              : _cocinaController.db
                  .collection(establecimientoValue)
                  .doc('pedidos')
                  .collection('items')
                  .where('estado', isEqualTo: statusFilter)
                  .snapshots()
                  .map(
                    (snapshot) =>
                        snapshot.docs
                            .map((doc) => PedidoModel.fromJson(doc.data()))
                            .toList(),
                  );

      return StreamBuilder<List<PedidoModel>>(
        stream: pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay órdenes ${statusFilter == 'pendiente' ? 'pendientes' : 'listas'}.',
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final productos = order.productos;

              return Card(
                color: Color(0xFF6e2c13),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesa: ${order.mesaId}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      ...productos.map((producto) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    producto['nombre'] ?? 'Producto sin nombre',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                                if (statusFilter == 'pendiente')
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Container(
                                      color: Colors.grey[300],
                                      child: IconButton(
                                        icon: Icon(Icons.check, size: 20, ),
                                        onPressed: () {
                                          _cocinaController
                                              .cambiarEstadoAPreparado(
                                                order.id,
                                              );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (producto['notas'] != null &&
                                producto['notas'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Notas: ${producto['notas']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            if (producto['cantidad'] != null &&
                                producto['cantidad'] > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Cantidad: ${producto['cantidad']}',
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ),
                              ),
                            SizedBox(height: 8),
                            Divider(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
