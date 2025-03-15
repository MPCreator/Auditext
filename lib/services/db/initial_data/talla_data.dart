import 'package:sqflite/sqflite.dart';

class TallaData {
  static Future<void> insertInitialSizes(Database db) async {
    await db.execute('''
    INSERT INTO Talla (rango) VALUES
      ('2-4'),
      ('4-6'),
      ('6-8'),
      ('8-10'),
      ('10-12'),
      ('12-14'),
      ('14-16'),
      ('S'),
      ('M'),
      ('L'),
      ('SM'),
      ('ML'),
      ('M-L'),
      ('XL'),
      ('TU');
    ''');
  }
}
