import 'package:sqflite/sqflite.dart';

class DescripcionData {
  static Future<void> insertInitialDescriptions(Database db) async {
    await db.execute('''
    INSERT INTO Descripcion (descripcion) VALUES
      ('ABERTURA DE PIERNA'),
      ('ABERTURA DE PIERNA DELANTERA'),
      ('ABERTURA EN BASTA'),
      ('ALTO COSTADO'),
      ('ALTO DE COSTADO'),
      ('ALTO DE PRETINA'),
      ('ALTO PRETINA'),
      ('ANCHO ALTURA INICIO TEJIDO DE ALGODÓN'),
      ('ANCHO CADERA'),
      ('ANCHO DE CUERPO'),
      ('ANCHO DE PECHO'),
      ('ANCHO DE PRETINA'),
      ('ANCHO DE TIRO'),
      ('ANCHO PARTE ESPALDA'),
      ('CADERA 1CM BAJO PRETINA'),
      ('LARGO CENTRO DELANTERO'),
      ('LARGO CENTRO ESPALDA'),
      ('LARGO COSTADO'),
      ('LARGO DE PRENDA'),
      ('LARGO DESDE HPS'),
      ('LARGO HPS'),
      ('LARGO TOTAL'),
      ('LARGO TOTAL SIN BROCHE'),
      ('MEDIDA DE PRETINA RELAJADA'),
      ('SISA RECTA'),
      ('TIRO ESPALDA');
    ''');
  }
}
