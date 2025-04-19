import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class RoleLoadingScreen {
  Future<void> checkUserRole({required BuildContext contexto}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Consulta el documento del usuario en Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          // Traemos el rol del usuario que acaba de iniciar sesion
          final rol = userDoc.data()?['rol'] ?? '';
          // Validamos el rol de cada usuario
          if (rol == 'Gerente') {
            contexto.go('/manager', extra: userDoc.data());
          }
          else if (rol == 'Cocina') {
            contexto.go('/no-role');
          }
          else if (rol == 'Mesero') {
            contexto.go('/waiter');
          }
          else if (rol == '') {
            contexto.go('/no-role');
          }
        }
      } else {
        contexto.go('/');
      }
    } catch (e) {
      print('Error al verificar rol: $e');
      contexto.go('/');
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Verifica si hay un usuario logueado
  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Devuelve el usuario actual (puede ser null)
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
