class ImagenMedida {
  int? id;
  final int elementoId;
  final String imagen;
  String titulo;

  ImagenMedida({
    this.id,
    required this.elementoId,
    required this.imagen,
    required this.titulo,
  });

  factory ImagenMedida.fromMap(Map<String, dynamic> map) {
    return ImagenMedida(
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