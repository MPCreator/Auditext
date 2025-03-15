class MargenError {
  int? id;
  final int margen;

  MargenError({
    this.id,
    required this.margen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'margen': margen,
    };
  }

  factory MargenError.fromMap(Map<String, dynamic> map) {
    return MargenError(
      id: map['id'],
      margen: map['margen'],
    );
  }
}