import 'package:quickbites_app/src/env/hash.dart';

class FacturaModel {
  final String id;
  final String mesaId;
  final String camarero;
  final double total;
  final DateTime fecha;
  final List<Map<String, dynamic>> productos;
  final Map<String, dynamic> datosFactura;

  FacturaModel({
    String? id,
    required this.mesaId,
    required this.camarero,
    required this.total,
    required this.fecha,
    required this.productos,
    required this.datosFactura,
  }) : id =
           id ??
           CRC32Hasher().generar(
             '$mesaId-${fecha.millisecondsSinceEpoch}-$camarero',
           );

  factory FacturaModel.fromJson(Map<String, dynamic> json) => FacturaModel(
    id: json['id'],
    mesaId: json['mesaId'],
    camarero: json['camarero'],
    total: json['total'].toDouble(),
    fecha: DateTime.parse(json['fecha']),
    productos: List<Map<String, dynamic>>.from(json['productos']),
    datosFactura: Map<String, dynamic>.from(json['datosFactura'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mesaId': mesaId,
    'camarero': camarero,
    'total': total,
    'fecha': fecha.toIso8601String(),
    'productos': productos,
    'datosFactura': datosFactura,
  };
}
