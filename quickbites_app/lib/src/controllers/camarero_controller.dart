import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/mesa_model.dart';
import '../models/pedido_model.dart';

class CamareroController extends GetxController {
  final db = FirebaseFirestore.instance;
  final storage = GetStorage();
  late String establecimiento;
  late String codigoCamarero;

  var mesasDisponibles = <MesaModel>[].obs;
  var pedidosDelCamarero = <PedidoModel>[].obs;
  var mesasOcupadas = <MesaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    establecimiento = storage.read('establecimiento') ?? '';
    codigoCamarero = storage.read('codigo') ?? '';
    cargarMesasDisponibles();
    cargarPedidosDelCamarero();
    //cargarMesasOcupadas();
  }

  /*void cargarMesasOcupadas() {
    FirebaseFirestore.instance
        .collection('tables')
        .where('status', isEqualTo: 'occupied')
        .snapshots()
        .listen((snapshot) {
          final tables = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }*/

  String formatOccupiedTime(Timestamp? timestamp) {
    if (timestamp == null) return "Ocupada";
    return "Ocupada desde: ${DateFormat.jm().format(timestamp.toDate())}";
  }

  Stream<List<Map<String, dynamic>>> getOccupiedTablesStream() {
    return FirebaseFirestore.instance
        .collection('tables')
        .where('status', isEqualTo: 'occupied')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> cargarMesasDisponibles() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('mesas')
            .collection('items')
            .where('ocupada', isEqualTo: false)
            .get();

    mesasDisponibles.value =
        snapshot.docs.map((e) => MesaModel.fromJson(e.data())).toList();
    storage.write(
      'mesasDisponibles',
      mesasDisponibles.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> cargarPedidosDelCamarero() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('pedidos')
            .collection('items')
            .where('codigoCamarero', isEqualTo: codigoCamarero)
            .get();

    pedidosDelCamarero.value =
        snapshot.docs.map((e) => PedidoModel.fromJson(e.data())).toList();
    storage.write(
      'pedidosCamarero',
      pedidosDelCamarero.map((e) => e.toJson()).toList(),
    );
  }

  Stream<List<MesaModel>> getMesasDisponiblesStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .where('ocupada', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final mesas =
              snapshot.docs
                  .map((doc) => MesaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'mesas_disponibles',
            mesas.map((e) => e.toJson()).toList(),
          );
          return mesas;
        });
  }

  Stream<List<PedidoModel>> getPedidosDelCamareroStream(
    String establecimiento,
    String codigoCamarero,
  ) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('pedidos')
        .collection('items')
        .where('codigoCamarero', isEqualTo: codigoCamarero)
        .snapshots()
        .map((snapshot) {
          final pedidos =
              snapshot.docs
                  .map((doc) => PedidoModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'pedidos_camarero',
            pedidos.map((e) => e.toJson()).toList(),
          );
          return pedidos;
        });
  }

  Future<void> tomarPedido(PedidoModel pedido, String mesaId) async {
    // Marcar mesa como ocupada
    await db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .doc(mesaId)
        .update({'ocupada': true});
    // Guardar pedido
    await db
        .collection(establecimiento)
        .doc('pedidos')
        .collection('items')
        .doc(pedido.id)
        .set(pedido.toJson());
    await cargarPedidosDelCamarero();
    await cargarMesasDisponibles();
  }

  Future<void> cancelarPedido(String pedidoId, String mesaId) async {
    await db
        .collection(establecimiento)
        .doc('pedidos')
        .collection('items')
        .doc(pedidoId)
        .delete();
    // Si ya no hay más pedidos activos en esa mesa, liberarla
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('pedidos')
            .collection('items')
            .where('mesaId', isEqualTo: mesaId)
            .get();
    if (snapshot.docs.isEmpty) {
      await db
          .collection(establecimiento)
          .doc('mesas')
          .collection('items')
          .doc(mesaId)
          .update({'ocupada': false});
    }
    await cargarPedidosDelCamarero();
    await cargarMesasDisponibles();
  }

  Future<void> seleccionarMesa(String mesaId, String mesaNumber) async {
    await FirebaseFirestore.instance.collection('tables').doc(mesaId).update({
      'status': 'occupied',
      'occupiedAt': FieldValue.serverTimestamp(),
    });
     await db
      .collection(establecimiento)
      .doc('mesas')
      .collection('items')
      .doc(mesaId)
      .update({
        'ocupada': true,
        'status': 'occupied',
        'occupiedAt': FieldValue.serverTimestamp(),
      });
  }

  Future<void> mandarAFacturar(String mesaId, String infoExtra) async {
    final pedidosSnapshot =
        await db
            .collection(establecimiento)
            .doc('pedidos')
            .collection('items')
            .where('mesaId', isEqualTo: mesaId)
            .get();

    final pedidos =
        pedidosSnapshot.docs
            .map((e) => PedidoModel.fromJson(e.data()))
            .toList();
    double total = pedidos.fold(0, (sum, item) => sum + item.total);

    await db
        .collection(establecimiento)
        .doc('facturacion')
        .collection('items')
        .doc(mesaId)
        .set({
          'mesaId': mesaId,
          'pedidos': pedidos.map((e) => e.toJson()).toList(),
          'total': total,
          'codigoCamarero': codigoCamarero,
          'hora': DateTime.now().toIso8601String(),
          'infoExtra': infoExtra,
        });
  }
}
