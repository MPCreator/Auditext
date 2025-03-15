class Inspeccion {
  int? id;
  final int nqaId;
  final int tipoInspeccionId;
  final int nivelInspeccionId;
  final String tamanoLote;
  final int tamanoMuestra;
  final int aprobar;
  final int rechazar;

  Inspeccion({
    this.id,
    required this.nqaId,
    required this.tipoInspeccionId,
    required this.nivelInspeccionId,
    required this.tamanoLote,
    required this.tamanoMuestra,
    required this.aprobar,
    required this.rechazar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nqaId': nqaId,
      'tipoInspeccionId': tipoInspeccionId,
      'nivelInspeccionId': nivelInspeccionId,
      'tamanoLote': tamanoLote,
      'tamanoMuestra': tamanoMuestra,
      'aprobar': aprobar,
      'rechazar': rechazar,
    };
  }

  factory Inspeccion.fromMap(Map<String, dynamic> map) {
    return Inspeccion(
      id: map['id'],
      nqaId: map['nqaId'],
      tipoInspeccionId: map['tipoInspeccionId'],
      nivelInspeccionId: map['nivelInspeccionId'],
      tamanoLote: map['tamanoLote'],
      tamanoMuestra: map['tamanoMuestra'],
      aprobar: map['aprobar'],
      rechazar: map['rechazar'],
    );
  }
}
