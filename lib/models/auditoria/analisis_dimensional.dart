class AnalisisDimensional {
  int? id;
  final int elementoId;
  final String talla;
  final String toleranciaDescripcion;
  final String color;
  final double? valor;

  AnalisisDimensional({
    this.id,
    required this.elementoId,
    required this.talla,
    required this.toleranciaDescripcion,
    required this.color,
    this.valor,
  });

  factory AnalisisDimensional.fromMap(Map<String, dynamic> map) {
    return AnalisisDimensional(
      id: map['id'],
      elementoId: map['elementoId'],
      talla: map['talla'],
      toleranciaDescripcion: map['toleranciaDescripcion'],
      color: map['color'],
      valor: map['valor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'elementoId': elementoId,
      'talla': talla,
      'toleranciaDescripcion': toleranciaDescripcion,
      'color': color,
      'valor': valor,
    };
  }
}
