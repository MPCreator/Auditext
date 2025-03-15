class UserSettings {
  int? id;
  final String seccion;
  final int tipoInspeccionId;
  final int nivelInspeccionId;
  final int nqaId;
  final int margenErrorId;

  UserSettings({
    this.id,
    required this.seccion,
    required this.tipoInspeccionId,
    required this.nivelInspeccionId,
    required this.nqaId,
    required this.margenErrorId,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'],
      seccion: map['seccion'] as String,
      tipoInspeccionId: map['tipoInspeccionId'] as int,
      nivelInspeccionId: map['nivelInspeccionId'] as int,
      nqaId: map['nqaId'] as int,
      margenErrorId: map['margenErrorId'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seccion': seccion,
      'tipoInspeccionId': tipoInspeccionId,
      'nivelInspeccionId': nivelInspeccionId,
      'nqaId': nqaId,
      'margenErrorId': margenErrorId,
    };
  }
}
