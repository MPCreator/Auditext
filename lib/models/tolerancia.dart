import 'dart:convert';

class Tolerancia {
  int? id;
  final int idEstilo;
  final Map<String, Map<String, double>> datos;

  Tolerancia({
    this.id,
    required this.idEstilo,
    required this.datos,
  });

  factory Tolerancia.fromMap(Map<String, dynamic> map) {
    return Tolerancia(
      id: map['id'],
      idEstilo: map['id_estilo'],
      datos: _parseDatos(map['datos']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_estilo': idEstilo,
      'datos': jsonEncode(datos),
    };
  }

  // Función para manejar la deserialización de los datos JSON correctamente
  static Map<String, Map<String, double>> _parseDatos(dynamic datos) {
    if (datos == null) return {};
    final Map<String, dynamic> rawDatos = jsonDecode(datos);
    final Map<String, Map<String, double>> parsedDatos = {};

    rawDatos.forEach((talla, descripciones) {
      parsedDatos[talla] = Map<String, double>.from(descripciones.map(
              (descripcion, valor) => MapEntry(descripcion, valor.toDouble())));
    });

    return parsedDatos;
  }
}
