import '../../../../models/inspeccion/margen_error.dart';
import '../../database_manager.dart';

class MargenErrorDAO {
  Future<int> insertMargenError(MargenError nivelMargenError) async {
    final db = await DatabaseManager().database;
    return await db.insert('MargenError', nivelMargenError.toMap());
  }

  Future<List<MargenError>> getMargenErrores() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('MargenError');
    return List.generate(
      maps.length,
          (i) => MargenError.fromMap(maps[i]),
    );
  }

  Future<int> updateMargenError(MargenError nivelMargenError) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'MargenError',
      nivelMargenError.toMap(),
      where: 'id = ?',
      whereArgs: [nivelMargenError.id],
    );
  }

  Future<int> deleteMargenError(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'MargenError',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}