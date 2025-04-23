import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/cocina_controller.dart';
import 'package:quickbites_app/src/models/pedido_model.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class HomePageKitchen extends StatefulWidget {
  @override
  _HomePageKitchenState createState() => _HomePageKitchenState();
}

class _HomePageKitchenState extends State<HomePageKitchen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CocinaController _cocinaController = Get.put(CocinaController());
  final UserController userController = Get.find<UserController>();

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
        title: Text('Cocina', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          onPressed: () {
            userController.signOut();
            context.goNamed('login'.toUpperCase());
          },
          icon: Icon(Icons.logout_rounded, size: 35, color: Colors.red),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: [Tab(text: 'Pendientes'), Tab(text: 'Listos')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('pendiente'),
          _buildOrdersList('preparado'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String statusFilter) {
    return Obx(() {
      final establecimientoValue = _cocinaController.establecimiento.value;

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
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mesa: ${order.mesaId}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (statusFilter == 'pendiente')
                            ElevatedButton(
                              onPressed: () {
                                _cocinaController.cambiarEstadoAPreparado(
                                  order.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Listo'),
                            ),
                          if (statusFilter == 'preparado')
                            ElevatedButton(
                              onPressed: () {
                                _cocinaController.cambiarEstadoAEntregado(
                                  order.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Entregado'),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ...productos.map((producto) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: _getProductIcon(
                                      producto['nombre'] ?? '',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              producto['nombre'] ??
                                                  'Producto sin nombre',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (producto['cantidad'] != null &&
                                              producto['cantidad'] > 1)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'x${producto['cantidad']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (producto['notas'] != null &&
                                          producto['notas']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            producto['notas'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  bool _isBebida(String productName) {
    productName = productName.toLowerCase();
    return productName.contains('jugo') ||
        productName.contains('refresco') ||
        productName.contains('bebida') ||
        productName.contains('agua') ||
        productName.contains('café') ||
        productName.contains('té');
  }

  Widget _getProductIcon(String productName) {
    if (_isBebida(productName)) {
      return Icon(Icons.local_drink, color: Colors.blue);
    } else {
      return Icon(Icons.restaurant, color: Colors.orange);
    }
  }
}
