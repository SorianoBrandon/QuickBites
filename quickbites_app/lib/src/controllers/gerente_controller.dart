import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mesa_model.dart';
import '../models/platillo_model.dart';
import '../models/categoria_model.dart';

class GerenteController extends GetxController {
  final storage = GetStorage();
  final db = FirebaseFirestore.instance;
  late String establecimiento;

  var mesas = <MesaModel>[].obs;
  var platillos = <PlatilloModel>[].obs;
  var categorias = <CategoriaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    establecimiento = storage.read('establecimiento') ?? '';
    cargarMesas();
    cargarPlatillos();
    cargarCategorias();
  }

  // 🚪 MESAS
  Future<void> cargarMesas() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('mesas')
            .collection('items')
            .get();
    mesas.value =
        snapshot.docs.map((e) => MesaModel.fromJson(e.data())).toList();
    storage.write('mesas', mesas.map((e) => e.toJson()).toList());
  }

  Stream<List<CategoriaModel>> getCategoriasStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final categorias =
              snapshot.docs
                  .map((doc) => CategoriaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'categorias',
            categorias.map((e) => e.toJson()).toList(),
          );
          return categorias;
        });
  }

  Stream<List<PlatilloModel>> getPlatillosStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('platillos')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final platillos =
              snapshot.docs
                  .map((doc) => PlatilloModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'platillos',
            platillos.map((e) => e.toJson()).toList(),
          );
          return platillos;
        });
  }

  Stream<List<MesaModel>> getMesasStream(String establecimiento) {
    return FirebaseFirestore.instance
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final mesas =
              snapshot.docs
                  .map((doc) => MesaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write('mesas', mesas.map((e) => e.toJson()).toList());
          return mesas;
        });
  }

  Future<void> agregarMesa(MesaModel mesa) async {
    await db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .doc(mesa.id)
        .set(mesa.toJson());
    await cargarMesas();
  }

  Future<void> editarMesa(MesaModel mesa) async {
    await db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .doc(mesa.id)
        .update(mesa.toJson());
    await cargarMesas();
  }

  Future<void> eliminarMesa(String id) async {
    await db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .doc(id)
        .delete();
    await cargarMesas();
  }

  // 🍽️ PLATILLOS
  Future<void> cargarPlatillos() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('platillos')
            .collection('items')
            .get();
    platillos.value =
        snapshot.docs.map((e) => PlatilloModel.fromJson(e.data())).toList();
    storage.write('platillos', platillos.map((e) => e.toJson()).toList());
  }

  Future<void> agregarPlatillo(PlatilloModel platillo) async {
    await db
        .collection(establecimiento)
        .doc('platillos')
        .collection('items')
        .doc(platillo.id)
        .set(platillo.toJson());
    await cargarPlatillos();
  }

  Future<void> editarPlatillo(PlatilloModel platillo) async {
    await db
        .collection(establecimiento)
        .doc('platillos')
        .collection('items')
        .doc(platillo.id)
        .update(platillo.toJson());
    await cargarPlatillos();
  }

  Future<void> eliminarPlatillo(String id) async {
    await db
        .collection(establecimiento)
        .doc('platillos')
        .collection('items')
        .doc(id)
        .delete();
    await cargarPlatillos();
  }

  // 🗂️ CATEGORÍAS
  Future<void> cargarCategorias() async {
    final snapshot =
        await db
            .collection(establecimiento)
            .doc('categorias')
            .collection('items')
            .get();
    categorias.value =
        snapshot.docs.map((e) => CategoriaModel.fromJson(e.data())).toList();
    storage.write('categorias', categorias.map((e) => e.toJson()).toList());
  }

  Future<void> agregarCategoria(CategoriaModel cat) async {
    await db
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .doc(cat.id)
        .set(cat.toJson());
    await cargarCategorias();
  }

  Future<void> editarCategoria(CategoriaModel cat) async {
    await db
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .doc(cat.id)
        .update(cat.toJson());
    await cargarCategorias();
  }

  Future<void> eliminarCategoria(String id) async {
    await db
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .doc(id)
        .delete();
    await cargarCategorias();
  }
}
