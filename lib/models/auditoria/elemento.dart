class Elemento {
  int? id;
  final int? auditoriaId;
  final String codigo;
  final String descripcion;
  int totalGeneral;
  int totalAuditar;
  Map<String, int> colores;
  Map<String, int> tallas;
  String? nota;

  Elemento({
    this.id,
    required this.auditoriaId,
    required this.codigo,
    required this.descripcion,
    required this.totalGeneral,
    required this.totalAuditar,
    required this.colores,
    required this.tallas,
    this.nota,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auditoriaId': auditoriaId,
      'codigo': codigo,
      'descripcion': descripcion,
      'totalGeneral': totalGeneral,
      'totalAuditar': totalAuditar,
      'colores': colores.entries.map((e) => "${e.key}:${e.value}").join(","),
      'tallas': tallas.entries.map((e) => "${e.key}:${e.value}").join(","),
      'nota': nota,
    };
  }

  factory Elemento.fromMap(Map<String, dynamic> map) {
    return Elemento(
      id: map['id'],
      auditoriaId: map['auditoriaId'],
      codigo: map['codigo'],
      descripcion: map['descripcion'],
      totalGeneral: map['totalGeneral'],
      totalAuditar: map['totalAuditar'],
      colores: Map.fromEntries(
        (map['colores'] as String).split(",").map((e) {
          final parts = e.split(":");
          return MapEntry(parts[0], int.parse(parts[1]));
        }),
      ),
      tallas: Map.fromEntries(
        (map['tallas'] as String).split(",").map((e) {
          final parts = e.split(":");
          return MapEntry(parts[0], int.parse(parts[1]));
        }),
      ),
      nota: map['nota'] as String?,
    );
  }
}
