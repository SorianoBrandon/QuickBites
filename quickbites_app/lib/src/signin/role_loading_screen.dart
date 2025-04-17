import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class RoleLoadingScreen {

  Future<void> checkUserRole({
    required BuildContext context,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) { 
        // Consulta el documento del usuario en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
      if (userDoc.exists) {
        // Traemos el rol del usuario que acaba de iniciar sesion
        final rol = userDoc.data()?['rol'] ?? '';
        // Validamos el rol de cada usuario
        if ( rol == 'Gerente' ) { context.go('/manager', extra: userDoc.data() ); } 
        if ( rol == 'Cocina'  ) { context.go('/no-role');  }
        if ( rol == 'Mesero'  ) { context.go('/no-role');  }
      }
    }
    } catch (e) {
      print('Error al verificar rol: $e');
      context.go('/login');
    }
  }

}