import 'package:quickbites_app/src/env/hash.dart';

class PedidoModel {
  final String id;
  final String mesaId;
  final String codigoCamarero;
  final String estado; // pendiente, preparado, etc.
  final List<Map<String, dynamic>> productos; // id, nombre, cantidad, precio
  final DateTime hora;
  final double total;

  PedidoModel({
    String? id,
    required this.mesaId,
    required this.codigoCamarero,
    required this.estado,
    required this.productos,
    required this.hora,
    required this.total,
  }) : id =
           id ??
           CRC32Hasher().generar(
             '$mesaId-${hora.millisecondsSinceEpoch}-$codigoCamarero',
           );

  factory PedidoModel.fromJson(Map<String, dynamic> json) => PedidoModel(
    id: json['id'],
    mesaId: json['mesaId'],
    codigoCamarero: json['codigoCamarero'],
    estado: json['estado'],
    productos: List<Map<String, dynamic>>.from(json['productos']),
    hora: DateTime.parse(json['hora']),
    total: (json['total'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mesaId': mesaId,
    'codigoCamarero': codigoCamarero,
    'estado': estado,
    'productos': productos,
    'hora': hora.toIso8601String(),
    'total': total,
  };
}
