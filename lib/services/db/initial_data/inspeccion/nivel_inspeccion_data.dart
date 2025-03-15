
import 'package:sqflite/sqflite.dart';

class NivelInspeccionData {
  static Future<void> insertInitialNivelInspecciones(Database db) async {
    await db.execute('''
    INSERT INTO NivelInspeccion (nombre) VALUES
      ('I'),
      ('II'),
      ('III');
    ''');
  }
}
