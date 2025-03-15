import '../../../../models/auditoria/analisis_dimensional.dart';
import '../../database_manager.dart';

class AnalisisDimensionalDAO {
  Future<int> insertAnalisisDimensional(AnalisisDimensional AnalisisDimensional) async {
    final db = await DatabaseManager().database;
    return await db.insert('AnalisisDimensional', AnalisisDimensional.toMap());
  }

  Future<List<AnalisisDimensional>> getAnalisisDimensionals() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('AnalisisDimensional');
    return List.generate(
      maps.length,
          (i) => AnalisisDimensional.fromMap(maps[i]),
    );
  }

  Future<List<AnalisisDimensional>> getAnalisisDimensionalByElementoId(int elementoId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'AnalisisDimensional',
      where: 'elementoId = ?',
      whereArgs: [elementoId],
    );
    return List.generate(
      maps.length,
          (i) => AnalisisDimensional.fromMap(maps[i]),
    );
  }
  
  Future<int> updateAnalisisDimensional(AnalisisDimensional AnalisisDimensional) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'AnalisisDimensional',
      AnalisisDimensional.toMap(),
      where: 'id = ?',
      whereArgs: [AnalisisDimensional.id],
    );
  }

  Future<int> deleteAnalisisDimensional(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'AnalisisDimensional',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}