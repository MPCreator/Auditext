class TipoInspeccion {
  int? id;
  final String nombre;

  TipoInspeccion({
    this.id,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory TipoInspeccion.fromMap(Map<String, dynamic> map) {
    return TipoInspeccion(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}