import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickbites_app/src/env/hash.dart';

class AuthService {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Hasher hash = Hasher();

  // Función para crear usuario con email, contraseña y datos adicionales
  Future<void> createUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String direccion,
    required String telefono,
    required String establecimiento,
    required BuildContext context,
  }) async {
    try {
      // Crear usuario con Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Guardar datos adicionales en Firestore
        await _firestore
            .collection('restaurantes')
            .doc("restaurante#1")
            .collection('empleados')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'email': user.email,
              'code': hash.md5of(user.email!),
              'nombre': nombre,
              'apellido': apellido,
              'direccion': direccion,
              'telefono': telefono,
              'establecimiento': establecimiento,
              'createdAt': FieldValue.serverTimestamp(),
              'rol': "",
            });

        // return user;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario registrado exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email';
      } else if (e.code == 'invalid-email') {
        message = 'The email is not valid';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $message')));
      }
    }
  }
}
