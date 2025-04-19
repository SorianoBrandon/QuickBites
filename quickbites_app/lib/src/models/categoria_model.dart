class CategoriaModel {
  final String id;
  final String nombre;
  final List<String> subcategorias;

  CategoriaModel({
    required this.id,
    required this.nombre,
    required this.subcategorias,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) => CategoriaModel(
    id: json['id'],
    nombre: json['nombre'],
    subcategorias: List<String>.from(json['subcategorias']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'subcategorias': subcategorias,
  };
}
