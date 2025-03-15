import 'package:sqflite/sqflite.dart';

class MargenErrorData {
  static Future<void> insertInitialMargenErrores(Database db) async {
    await db.execute('''
    INSERT INTO MargenError (margen) VALUES
      (5),
      (10),
      (15);
    ''');
  }
}
