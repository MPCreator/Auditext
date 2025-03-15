
class Descripcion {
  int? id;
  final String descripcion;

  Descripcion({this.id, required this.descripcion});

  factory Descripcion.fromMap(Map<String, dynamic> map) {
    return Descripcion(
      id: map['id'],
      descripcion: map['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }
}