
class Estilo {
  int? id;
  final String nombre;

  Estilo({this.id, required this.nombre});

  factory Estilo.fromMap(Map<String, dynamic> map) {
    return Estilo(
      id: map['id'],
      nombre: map['nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
