import 'dart:convert';
import 'package:crypto/crypto.dart';

class Hasher {
  String sha256of(String input) {
    final bytes = utf8.encode(input); // Convierte el string a bytes
    final digest = sha256.convert(bytes); // Aplica SHA-256
    return digest.toString(); // Devuelve el hash como string hexadecimal
  }

  String md5of(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
