class EmpleadoModel {
  final String id;
  final String nombre;
  final String apellido;
  final String rol;
  final String establecimiento;
  final String uid;

  EmpleadoModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.establecimiento,
    required this.uid,
  });

  factory EmpleadoModel.fromJson(Map<String, dynamic> json, String id) {
    return EmpleadoModel(
      id: id,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      rol: json['rol'] ?? '',
      establecimiento: json['establecimiento'] ?? '',
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'establecimiento': establecimiento,
      'uid': uid,
    };
  }
}
