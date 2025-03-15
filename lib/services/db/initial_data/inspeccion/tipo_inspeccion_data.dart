import 'package:sqflite/sqflite.dart';

class TipoInspeccionData {
  static Future<void> insertInitialTipoInspecciones(Database db) async {
    await db.execute('''
    INSERT INTO TipoInspeccion (nombre) VALUES
      ('REDUCIDA'),
      ('NORMAL'),
      ('RIGUROSA');
    ''');
  }
}
