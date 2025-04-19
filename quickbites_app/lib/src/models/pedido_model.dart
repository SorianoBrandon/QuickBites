class PedidoModel {
  String id;
  String mesaId;
  String codigoCamarero;
  String estado; // pendiente, preparado, etc.
  List<Map<String, dynamic>> productos; // id, nombre, cantidad, precio
  DateTime hora;
  double total;

  PedidoModel({
    required this.id,
    required this.mesaId,
    required this.codigoCamarero,
    required this.estado,
    required this.productos,
    required this.hora,
    required this.total,
  });

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
