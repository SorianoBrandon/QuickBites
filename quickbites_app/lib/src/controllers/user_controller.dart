import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  final userRef = FirebaseFirestore.instance.collection('usuarios');

  /// Llama esto en el main() al arrancar la app
  Future<void> initUserDataOnAppStart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      firebaseUser.value = user;

      // Si ya está en local, carga desde ahí
      final localData = box.read('userData');
      if (localData != null) {
        userData.value = Map<String, dynamic>.from(localData);
      } else {
        // Si no, lo trae de Firestore
        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          userData.value = doc.data();
          box.write('userData', userData.value);
        }
      }
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      final UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      firebaseUser.value = cred.user;

      final doc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(firebaseUser.value!.uid)
              .get();

      if (doc.exists) {
        userData.value = doc.data();
        box.write('userData', userData.value);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Correo o Contraseña Incorrectos.',
        icon: Icon(Icons.error_sharp),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    firebaseUser.value = null;
    userData.value = null;
    box.remove('userData');
  }

  void loadUserData() {
    final storedData = box.read('userData');
    if (storedData != null) {
      userData.value = Map<String, dynamic>.from(storedData);
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;

  String get rol => userData.value?['rol'].toString().toUpperCase() ?? '';
  String get nombre => userData.value?['nombre'] ?? '';
  String get apellido => userData.value?['apellido'] ?? '';
  String get establecimiento => userData.value?['establecimiento'] ?? '';
  String get email => userData.value?['email'] ?? '';
  String get codigo => userData.value?['codigo'] ?? '';
  String get uid => userData.value?['uid'] ?? '';
}
