import 'package:sqflite/sqflite.dart';

class NqaData {
  static Future<void> insertInitialNQA(Database db) async {
    await db.execute('''
    INSERT INTO Nqa (nombre) VALUES
      ('2.5');
    ''');
  }
}
