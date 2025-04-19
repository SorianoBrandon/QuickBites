class CategoriaModel {
  final String nombre;
  final List<String> subcategorias;

  CategoriaModel({required this.nombre, required this.subcategorias});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      nombre: json['nombre'],
      subcategorias: List<String>.from(json['subcategorias']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'subcategorias': subcategorias};
  }
}
