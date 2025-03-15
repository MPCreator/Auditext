class Nqa {
  int? id;
  final String nombre;

  Nqa({
    this.id,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory Nqa.fromMap(Map<String, dynamic> map) {
    return Nqa(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}