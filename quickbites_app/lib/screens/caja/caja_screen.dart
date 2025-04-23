// Nota: En tu main.dart debes inicializar Firebase y GetStorage:
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await GetStorage.init();
//   runApp(MyApp());
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/caja_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:quickbites_app/src/models/caja_model.dart';


class CajaScreen extends StatefulWidget {
  @override
  _CajaScreenState createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  late final CajaController cajaController;
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    // Instanciar el controlador en initState garantiza que el binding esté listo
    cajaController = Get.put(CajaController());
  }

  @override
  Widget build(BuildContext context) {
    // Verificar que el establecimiento esté configurado
    print("ESOOOOOOOOOOOOOOOOOOOOO ${userController.email} ${userController.establecimiento}");
    if (userController.establecimiento.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Caja')),
        body: Center(
          child: Text(
            'Establecimiento no configurado.\nPor favor, configura el establecimiento antes de usar la caja.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Caja - ${userController.establecimiento}', style: TextStyle(color: Color(0xFF6e2c13)),),
          actions: [
            IconButton(
              onPressed: (){
                userController.signOut();
                context.go("/login");
              }, 
              icon: Icon(Icons.logout, color: Color(0xFF6e2c13),)
            ),
            SizedBox(width: 15.0,),
          ],
          bottom: TabBar(
            labelColor: Color(0xFF6e2c13),
            tabs: [Tab(text: 'Facturación'), Tab(text: 'Listas')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFacturacionTab(),
            _buildListasTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            if (userController.establecimiento.isNotEmpty) {
              cajaController.cargarFacturacion();
            }
          },
        ),
      ),
    );
  }

  Widget _buildFacturacionTab() {
    return Obx(() {
      final lista = cajaController.listaFacturacion;
      if (lista.isEmpty) {
        return Center(child: Text('No hay facturas actualmente'));
      }
      return ListView.builder(
        itemCount: lista.length,
        itemBuilder: (_, i) {
          final factura = lista[i];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Mesa: ${factura.mesaId}'),
              subtitle: Text(
                'Camarero: ${factura.camarero} | Total: \$${factura.total.toStringAsFixed(2)}',
              ),
              trailing: Text(
                '${factura.fecha.day}/${factura.fecha.month}/${factura.fecha.year}',
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildListasTab() {
    return StreamBuilder<List<FacturaModel>>(
      stream: cajaController.establecimiento.isEmpty
          ? Stream.value([])
          : cajaController.getFacturasListasStream(cajaController.establecimiento),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay facturas listas'));
        }
        final listas = snapshot.data!;
        return ListView.builder(
          itemCount: listas.length,
          itemBuilder: (_, i) {
            final factura = listas[i];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('Mesa: ${factura.mesaId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Camarero: ${factura.camarero}'),
                    Text('Total: \$${factura.total.toStringAsFixed(2)}'),
                    Text('Productos: ${factura.productos.length}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) {
                      await cajaController.marcarComoPagado(factura.mesaId);
                    }
                  },
                  child: Text('Pagar'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
