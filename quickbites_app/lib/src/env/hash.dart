import 'dart:convert';
import 'package:crclib/catalog.dart';  
// import 'package:crclib/crclib.dart';   

class CRC32Hasher {
  /// Genera un CRC32 (hexadecimal de 8 caracteres) a partir de un String
  String generar(String input) {
    final bytes = utf8.encode(input);               // Codifica el texto
    final crc = Crc32();                            // Algoritmo CRC32
    final digest = crc.convert(bytes);               
    return digest.toRadixString(16).padLeft(8,'0');
  }
} 