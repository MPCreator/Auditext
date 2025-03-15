class NivelInspeccion {
  int? id;
  final String nombre;

  NivelInspeccion({
    this.id,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory NivelInspeccion.fromMap(Map<String, dynamic> map) {
    return NivelInspeccion(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}