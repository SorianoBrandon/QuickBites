import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuScreen extends StatefulWidget {
  final String mesaId;
  final String mesaNumber;

  const MenuScreen({
    super.key,
    required this.mesaId,
    required this.mesaNumber,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<Map<String, dynamic>> _carrito = [];
  DocumentSnapshot? _mesaData; // Para almacenar los datos de la mesa

  @override
  void initState() {
    super.initState();
    _cargarDatosMesa();
  }

  Future<void> _cargarDatosMesa() async {
    final mesaSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .doc(widget.mesaId)
        .get();
    setState(() {
      _mesaData = mesaSnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú - Mesa ${widget.mesaNumber}'),
        backgroundColor: Colors.redAccent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  _mostrarCarrito(context);
                },
              ),
              if (_carrito.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      _carrito.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Encabezado con información de la mesa
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.redAccent.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${widget.mesaNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tables')
                          .doc(widget.mesaId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            'Cargando estado...',
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        final status = snapshot.data!['status'] ?? 'available';
                        return Text(
                          status == 'available' ? 'Disponible' : 'Ocupada',
                          style: TextStyle(
                            color: status == 'available' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Capacidad: ${_mesaData?['capacidad'] ?? '2'} personas', // Corregido: usando _mesaData
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // Lista de categorías/ítems del menú
          Expanded(
            child: _buildListaMenu(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _finalizarOrden(context),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  Widget _buildListaMenu() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar el menú'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(item['nombre']),
                subtitle: Text('\$${item['precio']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _carrito.add({
                        'id': items[index].id,
                        'nombre': item['nombre'],
                        'precio': item['precio'],
                        'cantidad': 1,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['nombre']} agregado al pedido'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarCarrito(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tu Pedido - Mesa ${widget.mesaNumber}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _carrito.length,
                itemBuilder: (context, index) {
                  final item = _carrito[index];
                  return ListTile(
                    title: Text(item['nombre']),
                    subtitle: Text('Cantidad: ${item['cantidad']}'),
                    trailing: Text('\$${item['precio']}'),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Confirmar pedido
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Confirmar Pedido'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _finalizarOrden(BuildContext context) {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega items al pedido primero')),
      );
      return;
    }

    // Aquí iría la lógica para guardar la orden en Firebase
    // y actualizar el estado de la mesa

    Navigator.pop(context); // Regresar a la pantalla anterior
  }
}