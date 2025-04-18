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

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _carrito = [];
  DocumentSnapshot? _mesaData;
  bool _enviandoACocina = false;
  late TabController _tabController;
  
  // Define las categorías y sus íconos correspondientes
  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Postres', 'icono': Icons.icecream, 'coleccion': 'Postres'},
    {'nombre': 'Pizza', 'icono': Icons.local_pizza, 'coleccion': 'Pizza'},
    {'nombre': 'Pasta', 'icono': Icons.restaurant, 'coleccion': 'Pasta'},
    {'nombre': 'Bebidas', 'icono': Icons.coffee_outlined, 'coleccion': 'Bebidas'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categorias.length, vsync: this);
    _cargarDatosMesa();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: _categorias.map((categoria) {
            return Tab(
              icon: Icon(categoria['icono']),
              text: categoria['nombre'],
            );
          }).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
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
                  'Capacidad: ${_mesaData?['capacidad'] ?? '2'} personas',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // TabBarView con las categorías del menú
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categorias.map((categoria) {
                return _buildCategoriaMenu(categoria['coleccion']);
              }).toList(),
            ),
          ),
          // Botón "A cocinar"
          if (_carrito.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _enviandoACocina ? null : () => _enviarACocina(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _enviandoACocina 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.local_dining, color: Colors.white),
                label: Text(
                  _enviandoACocina ? 'ENVIANDO...' : 'A COCINAR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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

  Widget _buildCategoriaMenu(String coleccion) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(coleccion).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar productos de $coleccion'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(child: Text('No hay productos disponibles en $coleccion'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Si hay una imagen disponible
                    if (item['imagen'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Image.network(
                            item['imagen'],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, obj, stack) => Icon(
                              _getIconForCategory(coleccion),
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForCategory(coleccion),
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nombre'] ?? 'Producto sin nombre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item['descripcion'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item['descripcion'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${item['precio'] ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.orange, size: 36),
                                onPressed: () {
                                  setState(() {
                                    _carrito.add({
                                      'id': items[index].id,
                                      'nombre': item['nombre'] ?? 'Producto sin nombre',
                                      'precio': item['precio'] ?? 0.0,
                                      'cantidad': 1,
                                      'categoria': coleccion,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForCategory(String categoria) {
    switch (categoria) {
      case 'Postres':
        return Icons.icecream;
      case 'Pizza':
        return Icons.local_pizza;
      case 'Pasta':
        return Icons.restaurant;
      case 'Bebidas':
        return Icons.coffee_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }

  void _mostrarCarrito(BuildContext context) {
    double total = 0;
    for (var item in _carrito) {
      total += (item['precio'] * item['cantidad']);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que el modal pueda ocupar más espacio
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7, // 70% de la altura de la pantalla
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tu Pedido - Mesa ${widget.mesaNumber}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _carrito.isEmpty 
                  ? const Center(
                      child: Text('No hay productos en el carrito',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ))
                  : ListView.builder(
                      itemCount: _carrito.length,
                      itemBuilder: (context, index) {
                        final item = _carrito[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.2),
                              child: Icon(
                                _getIconForCategory(item['categoria'] ?? ''),
                                color: Colors.orange,
                              ),
                            ),
                            title: Text(item['nombre']),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      if (item['cantidad'] > 1) {
                                        item['cantidad']--;
                                      } else {
                                        _carrito.removeAt(index);
                                      }
                                    });
                                    Navigator.pop(context); // Cerrar el modal actual
                                    _mostrarCarrito(context); // Volver a abrirlo actualizado
                                  },
                                ),
                                Text('${item['cantidad']}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      item['cantidad']++;
                                    });
                                    Navigator.pop(context); // Cerrar el modal actual
                                    _mostrarCarrito(context); // Volver a abrirlo actualizado
                                  },
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _carrito.removeAt(index);
                                    });
                                    Navigator.pop(context); // Cerrar el modal actual
                                    _mostrarCarrito(context); // Volver a abrirlo actualizado
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carrito.isEmpty ? null : () {
                    Navigator.pop(context); // Cierra el modal
                    _enviarACocina(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _enviandoACocina 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'A COCINAR',
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
    );
  }

  void _enviarACocina(BuildContext context) async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega items al pedido primero')),
      );
      return;
    }

    setState(() {
      _enviandoACocina = true;
    });

    try {
      // Calcular el total del pedido
      double total = 0;
      for (var item in _carrito) {
        total += (item['precio'] * item['cantidad']);
      }

      // Crear pedido en Firestore
      await FirebaseFirestore.instance.collection('kitchen_orders').add({
        'mesaId': widget.mesaId,
        'mesaNumber': widget.mesaNumber,
        'items': _carrito,
        'total': total,
        'status': 'pending', // Estado inicial: pendiente
        'createdAt': FieldValue.serverTimestamp(),
        'waiterName': 'Mesero', // Debería venir de autenticación
      });

      // Actualizar estado de la mesa
      await FirebaseFirestore.instance.collection('tables').doc(widget.mesaId).update({
        'status': 'occupied',
        'currentOrderId': null, // Si necesitas asociar con el ID de la orden
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido enviado a cocina correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpiar carrito
      setState(() {
        _carrito.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _enviandoACocina = false;
      });
    }
  }

  void _finalizarOrden(BuildContext context) {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega items al pedido primero')),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar orden'),
          content: const Text(
            '¿Estás seguro de que deseas finalizar esta orden?\n\n'
            'Esto cerrará la mesa y la marcará como disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo
                
                try {
                  // Actualizar estado de la mesa a disponible
                  await FirebaseFirestore.instance
                      .collection('tables')
                      .doc(widget.mesaId)
                      .update({'status': 'available'});
                  
                  // Volver a la pantalla anterior
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mesa liberada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al finalizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('CONFIRMAR'),
            ),
          ],
        );
      },
    );
  }
}
