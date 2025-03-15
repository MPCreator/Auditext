
class Talla {
  int? id;
  final String rango;

  Talla({this.id, required this.rango});

  factory Talla.fromMap(Map<String, dynamic> map) {
    return Talla(
      id: map['id'],
      rango: map['rango'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rango': rango,
    };
  }
}
