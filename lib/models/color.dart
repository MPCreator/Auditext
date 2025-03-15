
class Color {
  int? id;
  final String nombre;

  Color({this.id, required this.nombre});

  // Convertir de mapa a objeto
  factory Color.fromMap(Map<String, dynamic> map) {
    return Color(
      id: map['id'],
      nombre: map['nombre'],
    );
  }

  // Convertir de objeto a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
