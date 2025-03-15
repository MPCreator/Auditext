import 'package:sqflite/sqflite.dart';

import '../../../models/estilo.dart';
import '../database_manager.dart';

class EstiloDao {

  Future<int> insertEstilo(Estilo estilo) async {
    final db = await DatabaseManager().database;

    return await db.insert(
      'Estilo',
      estilo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getEstiloIdByName(String nombre) async {
    final db = await DatabaseManager().database;
    final result = await db.query(
      'Estilo',
      columns: ['id'],
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null; // Retorna null si no se encuentra el estilo
  }

  Future<List<Estilo>> getEstilos() async {
    final db = await DatabaseManager().database;

    final List<Map<String, dynamic>> maps = await db.query('Estilo');
    return List.generate(maps.length, (i) => Estilo.fromMap(maps[i]));
  }

  Future<Estilo?> getById(int id) async {
    final db = await DatabaseManager().database;

    final maps = await db.query(
      'Estilo',
      where: 'id_estilo = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Estilo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEstilo(Estilo estilo) async {
    final db = await DatabaseManager().database;

    return await db.update(
      'Estilo',
      estilo.toMap(),
      where: 'id_estilo = ?',
      whereArgs: [estilo.id],
    );
  }

  Future<int> deleteEstilo(int id) async {
    final db = await DatabaseManager().database;

    return await db.delete(
      'estilos',
      where: 'id_estilo = ?',
      whereArgs: [id],
    );
  }
}
