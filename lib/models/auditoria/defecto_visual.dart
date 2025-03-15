class DefectoVisual {
  int? id;
  final int elementoId;
  final String codigo;
  final String descripcion;
  final String color;
  final String talla;
  final String origenZona;
  final int mayor;
  final int menor;

  DefectoVisual({
    this.id,
    required this.elementoId,
    required this.codigo,
    required this.descripcion,
    required this.color,
    required this.talla,
    required this.origenZona,
    required this.mayor,
    required this.menor,
  });

  factory DefectoVisual.fromMap(Map<String, dynamic> map) {
    return DefectoVisual(
      id: map['id'],
      elementoId: map['elementoId'],
      codigo: map['codigo'],
      descripcion: map['descripcion'],
      color: map['color'],
      talla: map['talla'],
      origenZona: map['origenZona'],
      mayor: map['mayor'],
      menor: map['menor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'elementoId': elementoId,
      'codigo': codigo,
      'descripcion': descripcion,
      'color': color,
      'talla': talla,
      'origenZona': origenZona,
      'mayor': mayor,
      'menor': menor,
    };
  }
}
