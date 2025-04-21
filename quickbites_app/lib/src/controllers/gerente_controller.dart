import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:quickbites_app/src/signin/manager/local_tab.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab.dart';
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
  RxInt selectedView = 0.obs;

  @override
  void onInit() {
    final userController = Get.find<UserController>();
    super.onInit();
    establecimiento = userController.establecimiento;
    cargarMesas();
    cargarPlatillos();
    cargarCategorias();
  }

  final views = [
    LocalTab(
      establecimiento: Get.find<UserController>().establecimiento,
      usuariosRef: UserController().userRef,
    ),
    MenuTab(),
  ];

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

  Future<void> agregarMesa(MesaModel mesa) async {
    try {
      final docRef = db
          .collection(establecimiento)
          .doc('mesas')
          .collection('items')
          .doc(mesa.id);

      final exists = await docRef.get();
      if (exists.exists) {
        Get.snackbar('¡Aviso!', 'Ya existe una mesa con ese Nombre.');
        return;
      }

      await docRef.set(mesa.toJson());
      mesas.add(mesa);
      storage.write('mesas', mesas.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al agregar mesa: $e');
    }
  }

  Future<void> editarMesa(MesaModel mesa) async {
    try {
      await db
          .collection(establecimiento)
          .doc('mesas')
          .collection('items')
          .doc(mesa.id)
          .update(mesa.toJson());
      final index = mesas.indexWhere((m) => m.id == mesa.id);
      if (index != -1) {
        mesas[index] = mesa;
        storage.write('mesas', mesas.map((e) => e.toJson()).toList());
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al editar mesa: $e');
    }
  }

  Future<void> eliminarMesa(String id) async {
    try {
      await db
          .collection(establecimiento)
          .doc('mesas')
          .collection('items')
          .doc(id)
          .delete();
      mesas.removeWhere((mesa) => mesa.id == id);
      storage.write('mesas', mesas.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al eliminar mesa: $e');
    }
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
    try {
      final docRef = db
          .collection(establecimiento)
          .doc('platillos')
          .collection('items')
          .doc(platillo.id);

      final exists = await docRef.get();
      if (exists.exists) {
        Get.snackbar('¡Aviso!', 'Ya existe un platillo con este Nombre');
        return;
      }

      await docRef.set(platillo.toJson());
      platillos.add(platillo);
      storage.write('platillos', platillos.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al agregar platillo: $e');
    }
  }

  Future<void> editarPlatillo(PlatilloModel platillo) async {
    try {
      await db
          .collection(establecimiento)
          .doc('platillos')
          .collection('items')
          .doc(platillo.id)
          .update(platillo.toJson());
      final index = platillos.indexWhere((p) => p.id == platillo.id);
      if (index != -1) {
        platillos[index] = platillo;
        storage.write('platillos', platillos.map((e) => e.toJson()).toList());
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al editar platillo: $e');
    }
  }

  Future<void> eliminarPlatillo(String id) async {
    try {
      await db
          .collection(establecimiento)
          .doc('platillos')
          .collection('items')
          .doc(id)
          .delete();
      platillos.removeWhere((p) => p.id == id);
      storage.write('platillos', platillos.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al eliminar platillo: $e');
    }
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

  Future<void> agregarCategoria(CategoriaModel categoria) async {
    try {
      // Verificar si ya hay 4 categorías
      if (categorias.length >= 4) {
        Get.snackbar('¡Aviso!', 'Ya alcanzaste el máximo de 4 categorías');
        return;
      }

      final docRef = db
          .collection(establecimiento)
          .doc('categorias')
          .collection('items')
          .doc(categoria.nombre);

      final exists = await docRef.get();
      if (exists.exists) {
        Get.snackbar('¡Aviso!', 'Ya existe una categoría con ese nombre');
        return;
      }

      await docRef.set(categoria.toJson());

      categorias.add(categoria); // local
      storage.write('categorias', categorias.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al agregar categoría: $e');
    }
  }

  Future<void> editarCategoria(CategoriaModel categoria) async {
    try {
      await db
          .collection(establecimiento)
          .doc('categorias')
          .collection('items')
          .doc(categoria.nombre)
          .update(categoria.toJson());
      final index = categorias.indexWhere(
        (cat) => cat.nombre == categoria.nombre,
      );
      if (index != -1) {
        categorias[index] = categoria;
        storage.write('categorias', categorias.map((e) => e.toJson()).toList());
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al editar categoría: $e');
    }
  }

  Future<void> eliminarCategoria(String id) async {
    try {
      await db
          .collection(establecimiento)
          .doc('categorias')
          .collection('items')
          .doc(id)
          .delete();
      categorias.removeWhere((c) => c.nombre == id);
      storage.write('categorias', categorias.map((e) => e.toJson()).toList());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Error al eliminar categoría: $e');
    }
  }

  // 🔁 STREAMS
  Stream<List<MesaModel>> getMesasStream() {
    return db
        .collection(establecimiento)
        .doc('mesas')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final data =
              snapshot.docs
                  .map((doc) => MesaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write('mesas', data.map((e) => e.toJson()).toList());
          return data;
        });
  }

  Stream<List<PlatilloModel>> getPlatillosStream() {
    return db
        .collection(establecimiento)
        .doc('platillos')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final data =
              snapshot.docs
                  .map((doc) => PlatilloModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write('platillos', data.map((e) => e.toJson()).toList());
          return data;
        });
  }

  Stream<List<CategoriaModel>> getCategoriasStream() {
    return db
        .collection(establecimiento)
        .doc('categorias')
        .collection('items')
        .snapshots()
        .map((snapshot) {
          final data =
              snapshot.docs
                  .map((doc) => CategoriaModel.fromJson(doc.data()))
                  .toList();
          GetStorage().write(
            'categorias',
            data.map((e) => e.toJson()).toList(),
          );
          return data;
        });
  }
}
