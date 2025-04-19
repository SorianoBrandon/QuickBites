import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';

class CocinaController extends GetxController {
  final db = FirebaseFirestore.instance;
  final storage = GetStorage();
  late String establecimiento;

  var pedidosPendientes = <PedidoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    establecimiento = storage.read('establecimiento') ?? '';
    cargarPedidosPendientes();
  }

  Future<void> cargarPedidosPendientes() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('pedidos')
            .collection('items')
            .where('estado', isEqualTo: 'pendiente')
            .get();

    pedidosPendientes.value =
        snapshot.docs.map((e) => PedidoModel.fromJson(e.data())).toList();
    storage.write(
      'pedidosPendientes',
      pedidosPendientes.map((e) => e.toJson()).toList(),
    );
  }

  Stream<List<PedidoModel>> getPedidosPendientesStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('pedidos')
        .collection('items')
        .where('estado', isEqualTo: 'pendiente')
        .snapshots()
        .map((snapshot) {
          final pedidos =
              snapshot.docs
                  .map((doc) => PedidoModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'pedidos_pendientes',
            pedidos.map((e) => e.toJson()).toList(),
          );
          return pedidos;
        });
  }

  Future<void> cambiarEstadoAPreparado(String pedidoId) async {
    await db
        .collection(establecimiento)
        .doc('pedidos')
        .collection('items')
        .doc(pedidoId)
        .update({'estado': 'preparado'});
    await cargarPedidosPendientes();
  }
}
