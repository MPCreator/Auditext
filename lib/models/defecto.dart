import 'dart:convert'; // Para manejar JSON

class Defecto {
  int? id;
  final String codigo;
  final String nombre;
  final List<String> elementos;

  Defecto({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.elementos,
  });

  // Convertir de mapa a objeto
  factory Defecto.fromMap(Map<String, dynamic> map) {
    return Defecto(
      id: map['id'],
      codigo: map['codigo'],
      nombre: map['nombre'],
      elementos: List<String>.from(jsonDecode(map['elementos'])),
    );
  }

  // Convertir de objeto a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'elementos': jsonEncode(elementos),
    };
  }
}
