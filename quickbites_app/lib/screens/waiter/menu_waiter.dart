import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/camarero_controller.dart';
import 'package:quickbites_app/src/models/pedido_model.dart';
import 'package:quickbites_app/src/models/platillo_model.dart';


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
  final CamareroController _camareroController = Get.find<CamareroController>();
  bool _enviandoACocina = false;
  late TabController _tabController;
  String? _capacidadMesa;
  
  // Este mapa conecta las categorías con sus íconos correspondientes
  final Map<String, IconData> _iconosCategorias = {
    'Postres': Icons.icecream,
    'Pizza': Icons.local_pizza,
    'Pasta': Icons.restaurant,
    'Bebidas': Icons.coffee_outlined,
  };

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarDatosMesa();
  }

  // Lista dinámica de categorías que se cargará desde Firestore
  final RxList<Map<String, dynamic>> _categorias = <Map<String, dynamic>>[].obs;
  
  Future<void> _cargarCategorias() async {
    // Usa el establecimiento del controlador
    final establecimiento = _camareroController.establecimiento;
    
    final snapshot = await FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .get();
    
    // Crea la lista de categorías con sus íconos
    final categorias = snapshot.docs.map((doc) {
      final data = doc.data();
      final nombre = data['nombre'] as String;
      
      return {
        'nombre': nombre,
        'icono': _iconosCategorias[nombre] ?? Icons.restaurant_menu,
        'coleccion': nombre,
      };
    }).toList();
    
    // Si no hay categorías definidas, usa las por defecto
    if (categorias.isEmpty) {
      categorias.addAll([
        {'nombre': 'Postres', 'icono': Icons.icecream, 'coleccion': 'Postres'},
        {'nombre': 'Pizza', 'icono': Icons.local_pizza, 'coleccion': 'Pizza'},
        {'nombre': 'Pasta', 'icono': Icons.restaurant, 'coleccion': 'Pasta'},
        {'nombre': 'Bebidas', 'icono': Icons.coffee_outlined, 'coleccion': 'Bebidas'},
      ]);
    }
    
    setState(() {
      _categorias.assignAll(categorias);
      _tabController = TabController(length: _categorias.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosMesa() async {
    try {
      final mesaSnapshot = await FirebaseFirestore.instance
          .collection(_camareroController.establecimiento)
          .doc('mesas')
          .collection('items')
          .doc(widget.mesaId)
          .get();
      
      if (mesaSnapshot.exists) {
        setState(() {
          _capacidadMesa = mesaSnapshot.data()?['capacidad']?.toString() ?? '2';
        });
      } else {
        // Fallback a la nueva estructura si no existe en la antigua
        final tableSnapshot = await FirebaseFirestore.instance
          .collection('tables')
          .doc(widget.mesaId)
          .get();
        setState(() {
          _capacidadMesa = tableSnapshot.data()?['capacidad']?.toString() ?? '2';
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos de la mesa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categorias.isEmpty || !_tabController.hasListeners) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cargando Menú - Mesa ${widget.mesaNumber}'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                          .collection(_camareroController.establecimiento)
                          .doc('mesas')
                          .collection('items')
                          .doc(widget.mesaId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            'Cargando estado...',
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        final ocupada = snapshot.data!['ocupada'] ?? false;
                        return Text(
                          ocupada ? 'Ocupada' : 'Disponible',
                          style: TextStyle(
                            color: ocupada ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Capacidad: $_capacidadMesa personas',
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
                return _buildCategoriaMenu(categoria['nombre']);
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

  Widget _buildCategoriaMenu(String categoria) {
    final establecimiento = _camareroController.establecimiento;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(establecimiento)
          .doc('platillos')
          .collection('items')
          .where('categoria', isEqualTo: categoria)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar productos de $categoria'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(child: Text('No hay productos disponibles en $categoria'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;
            final PlatilloModel platillo = PlatilloModel.fromJson({
              'id': items[index].id, 
              'nombre': data['nombre'] ?? 'Producto sin nombre',
              'precio': (data['precio'] ?? 0.0),
              'categoria': data['categoria'] ?? categoria,
              'subcategoria': data['subcategoria'] ?? '',
            });
            
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
                    // Imagen o icono para el platillo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForCategory(platillo.categoria),
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
                            platillo.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (platillo.subcategoria.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                platillo.subcategoria,
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
                                '\$${platillo.precio.toStringAsFixed(2)}',
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
                                      'id': platillo.id,
                                      'nombre': platillo.nombre,
                                      'precio': platillo.precio,
                                      'cantidad': 1,
                                      'categoria': platillo.categoria,
                                    });
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${platillo.nombre} agregado al pedido'),
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
    return _iconosCategorias[categoria] ?? Icons.restaurant_menu;
  }

  void _mostrarCarrito(BuildContext context) {
    double total = 0;
    for (var item in _carrito) {
      total += (item['precio'] * item['cantidad']);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
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
                                    Navigator.pop(context);
                                    _mostrarCarrito(context);
                                  },
                                ),
                                Text('${item['cantidad']}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      item['cantidad']++;
                                    });
                                    Navigator.pop(context);
                                    _mostrarCarrito(context);
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
                                    Navigator.pop(context);
                                    _mostrarCarrito(context);
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
                    Navigator.pop(context);
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

      // Generar ID único para el pedido
      final pedidoId = FirebaseFirestore.instance.collection('pedidos').doc().id;
      
      // Crear el objeto PedidoModel
      final pedidoModel = PedidoModel(
        id: pedidoId,
        mesaId: widget.mesaId,
        codigoCamarero: _camareroController.codigoCamarero,
        estado: 'pendiente',
        productos: _carrito.map((item) => {
          'id': item['id'],
          'nombre': item['nombre'],
          'precio': item['precio'],
          'cantidad': item['cantidad'],
        }).toList(),
        hora: DateTime.now(),
        total: total,
      );

      // Usar el tomarPedido del controlador
      await _camareroController.tomarPedido(pedidoModel, widget.mesaId);

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
                
                final TextEditingController infoExtraController = TextEditingController();
                
                // Mostrar diálogo para pedir información adicional
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Información adicional'),
                      content: TextField(
                        controller: infoExtraController,
                        decoration: const InputDecoration(
                          hintText: 'Opcional: añade detalles para facturación',
                        ),
                        maxLines: 3,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Cierra el diálogo de info
                            
                            try {
                              // Enviar a facturar con el controlador
                              await _camareroController.mandarAFacturar(
                                widget.mesaId, 
                                infoExtraController.text
                              );
                              
                              // Volver a la pantalla anterior
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mesa liberada y pedido enviado a facturación'),
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
                          child: const Text('ENVIAR A FACTURACIÓN'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('CONFIRMAR'),
            ),
          ],
        );
      },
    );
  }
}