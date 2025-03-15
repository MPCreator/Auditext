class ImagenEmpaque {
  int? id;
  final int elementoId;
  final String imagen;
  String titulo;

  ImagenEmpaque({
    this.id,
    required this.elementoId,
    required this.imagen,
    required this.titulo,
  });

  factory ImagenEmpaque.fromMap(Map<String, dynamic> map) {
    return ImagenEmpaque(
      id: map['id'],
      elementoId: map['elementoId'],
      imagen: map['imagen'],
      titulo: map['titulo'] ?? 'Sin título',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'elementoId': elementoId,
      'imagen': imagen,
      'titulo': titulo,
    };
  }
}