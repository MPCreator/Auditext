import 'package:sqflite/sqflite.dart';

class ColorData {
  static Future<void> insertInitialColors(Database db) async {
    await db.execute('''
    INSERT INTO Color (nombre) VALUES
      ('NEGRO'),
      ('BLANCO'),
      ('ALMENDRA'),
      ('COGÑAC'),
      ('TABACO'),
      ('ACACIA'),
      ('CARBÓN'),
      ('CARIBE'),
      ('NATURAL'),
      ('CANELA'),
      ('CAFÉ'),
      ('MARRON BAG'),
      ('BEIGE'),
      ('GUINDO'),
      ('ROSADO BEBÉ'),
      ('AZUL MARINO'),
      ('BRIDAL ROSE'),
      ('GRIS OSCURO'),
      ('AZUL'),
      ('PIEL');
    ''');
  }
}
