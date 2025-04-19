import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/caja_model.dart';

class CajaController extends GetxController {
  final db = FirebaseFirestore.instance;
  final storage = GetStorage();
  late String establecimiento;

  var listaFacturacion = <FacturaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    establecimiento = storage.read('establecimiento') ?? '';
    cargarFacturacion();
  }

  Future<void> cargarFacturacion() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('facturacion')
            .collection('items')
            .get();
    listaFacturacion.value =
        snapshot.docs.map((e) => FacturaModel.fromJson(e.data())).toList();
    storage.write('facturas', listaFacturacion.map((e) => e.toJson()).toList());
  }

  Stream<List<FacturaModel>> getFacturasListasStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('facturacion')
        .collection('items')
        .where('estado', isEqualTo: 'listo')
        .snapshots()
        .map((snapshot) {
          final facturas =
              snapshot.docs
                  .map((doc) => FacturaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'facturas_listas',
            facturas.map((e) => e.toJson()).toList(),
          );
          return facturas;
        });
  }

  Future<void> marcarComoPagado(String mesaId) async {
    // Eliminar los pedidos activos de la mesa
    final pedidosSnapshot =
        await db
            .collection(establecimiento)
            .doc('pedidos')
            .collection('items')
            .where('mesaId', isEqualTo: mesaId)
            .get();

    for (var doc in pedidosSnapshot.docs) {
      await db
          .collection(establecimiento)
          .doc('pedidos')
          .collection('items')
          .doc(doc.id)
          .delete();
    }

    // Marcar la mesa como libre
    await db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .doc(mesaId)
        .update({'ocupada': false});

    // Eliminar facturación
    await db
        .collection(establecimiento)
        .doc('facturacion')
        .collection('items')
        .doc(mesaId)
        .delete();

    await cargarFacturacion();
  }
}
