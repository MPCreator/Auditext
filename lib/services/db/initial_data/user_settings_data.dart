import 'package:sqflite/sqflite.dart';

class UserSettingsData {
  static Future<void> insertInitialUserSettings(Database db) async {
    await db.execute('''
      INSERT INTO UserSettings (seccion, tipoInspeccionId, nivelInspeccionId, nqaId, margenErrorId) VALUES
        ('Defecto Visual',2, 2, 1, 1),
        ('Analisis Dimensional',2, 2, 1, 1);
      ''');
  }
}
