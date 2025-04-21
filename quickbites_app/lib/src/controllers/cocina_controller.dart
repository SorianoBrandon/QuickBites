import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';

class CocinaController extends GetxController {
  final db = FirebaseFirestore.instance;
  final storage = GetStorage();
  //late String establecimiento;

  final establecimiento=''.obs;

  var pedidosPendientes = <PedidoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    establecimiento.value = storage.read('establecimiento') ?? 'Restaurante';
    cargarPedidosPendientes();
  }

  Future<void> cargarPedidosPendientes() async {
    if (establecimiento.value.isEmpty) {
      print('Error: Establecimiento esta vacío');
      return;
    }
    try{
    final snapshot =
        await db
            .collection(establecimiento.value)
            .doc('pedidos')
            .collection('items')
            .where('estado', isEqualTo: 'pendiente')
            .get();

    pedidosPendientes.value =
        snapshot.docs.map((e) => PedidoModel.fromJson(e.data())).toList();
    storage.write(
      'pedidosPendientes',
      pedidosPendientes.map((e) => e.toJson()).toList(),
    );} catch (e) {
      print('Error al cargar pedidos pendientes: $e');
    }
  }

  Stream<List<PedidoModel>> getPedidosPendientesStream(String establecimientoParam) {
    final estab = establecimientoParam.isNotEmpty ? establecimientoParam : establecimiento.value;
    if (estab.isEmpty) {
      print('Error: Establecimiento esta vacío');
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection(estab)
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
    if (establecimiento.value.isEmpty) {
      print('Error: Establecimiento esta vacío');
      return;
    }
    try{
    await db
        .collection(establecimiento.value)
        .doc('pedidos')
        .collection('items')
        .doc(pedidoId)
        .update({'estado': 'preparado'});
    await cargarPedidosPendientes();
    }catch (e) {
      print('Error al cambiar el estado del pedido: $e');
    }
  }
}
