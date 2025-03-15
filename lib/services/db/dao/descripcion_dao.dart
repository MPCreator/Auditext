import 'package:sqflite/sqflite.dart';

import '../../../models/descripcion.dart';
import '../database_manager.dart';

class DescripcionDao {

  DescripcionDao();

  Future<int> insert(Descripcion descripcion) async {
    final db = await DatabaseManager().database;

    return await db.insert(
      'Descripcion',
      descripcion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Descripcion>> getAll() async {
    final db = await DatabaseManager().database;

    final List<Map<String, dynamic>> maps =
    await db.query('Descripcion');
    return List.generate(maps.length, (i) => Descripcion.fromMap(maps[i]));
  }

  Future<Descripcion?> getById(int id) async {
    final db = await DatabaseManager().database;

    final maps = await db.query(
      'Descripcion',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Descripcion.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Descripcion descripcion) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Descripcion',
      descripcion.toMap(),
      where: 'id = ?',
      whereArgs: [descripcion.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseManager().database;

    return await db.delete(
      'Descripcion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
