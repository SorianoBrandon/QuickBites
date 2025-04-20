import 'package:quickbites_app/src/env/hash.dart';

class MesaModel {
  final String? id;
  final String nombre;
  final int capacidad;
  final int? numero;
  final bool ocupada;

  MesaModel({
    String? id,
    required this.nombre,
    required this.capacidad,
    required this.ocupada,
    this.numero,
  }) : id = id ?? CRC32Hasher().generar(nombre);

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
    id: json['id'],
    nombre: json['nombre'],
    capacidad: json['capacidad'],
    ocupada: json['ocupada'],
    numero: json['numero'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'capacidad': capacidad,
    'ocupada': ocupada,
    'numero': numero,
  };
}


