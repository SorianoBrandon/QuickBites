class MesaModel {
  final String id;
  final int capacidad;
  final bool ocupada;

  MesaModel({required this.id, required this.capacidad, required this.ocupada});

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
    id: json['id'],
    capacidad: json['capacidad'],
    ocupada: json['ocupada'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'capacidad': capacidad,
    'ocupada': ocupada,
  };
}
