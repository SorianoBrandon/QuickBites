import 'package:quickbites_app/src/env/hash.dart';

class PlatilloModel {
  final String? id;
  final String nombre;
  final double precio;
  final String categoria;
  final String subcategoria;

  PlatilloModel({
    String? id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.subcategoria,
  }) : id = id ?? CRC32Hasher().generar(nombre);

  factory PlatilloModel.fromJson(Map<String, dynamic> json) => PlatilloModel(
    id: json['id'],
    nombre: json['nombre'],
    precio: json['precio'].toDouble(),
    categoria: json['categoria'],
    subcategoria: json['subcategoria'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'precio': precio,
    'categoria': categoria,
    'subcategoria': subcategoria,
  };
}
