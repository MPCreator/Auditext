class Auditoria {
  int? id;
  final String proveedor;
  final String paisOrigen;
  final String paisDestino;
  final String marca;
  final String fechaEntrega;
  final String fechaAuditoria;
  final String auditora;
  final String po;
  final String subgrupo;
  final String resultado;

  Auditoria({
    this.id,
    required this.proveedor,
    required this.paisOrigen,
    required this.paisDestino,
    required this.marca,
    required this.fechaEntrega,
    required this.fechaAuditoria,
    required this.auditora,
    required this.po,
    required this.subgrupo,
    required this.resultado,
  });

  factory Auditoria.fromMap(Map<String, dynamic> json) {
    return Auditoria(
      id: json['id'],
      proveedor: json['proveedor'],
      paisOrigen: json['paisOrigen'],
      paisDestino: json['paisDestino'],
      marca: json['marca'],
      fechaEntrega: json['fechaEntrega'],
      fechaAuditoria: json['fechaAuditoria'],
      auditora: json['auditora'],
      po: json['po'],
      subgrupo: json['subgrupo'],
      resultado: json['resultado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proveedor': proveedor,
      'paisOrigen': paisOrigen,
      'paisDestino': paisDestino,
      'marca': marca,
      'fechaEntrega': fechaEntrega,
      'fechaAuditoria': fechaAuditoria,
      'auditora': auditora,
      'po': po,
      'subgrupo': subgrupo,
      'resultado': resultado,
    };
  }
}
