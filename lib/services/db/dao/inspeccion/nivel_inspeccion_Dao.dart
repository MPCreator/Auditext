import '../../../../models/inspeccion/nivel_inspeccion.dart';
import '../../database_manager.dart';

class NivelInspeccionDAO {
  Future<int> insertNivelInspeccion(NivelInspeccion nivelInspeccion) async {
    final db = await DatabaseManager().database;
    return await db.insert('NivelInspeccion', nivelInspeccion.toMap());
  }

  Future<List<NivelInspeccion>> getNivelInspecciones() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('NivelInspeccion');
    return List.generate(
      maps.length,
          (i) => NivelInspeccion.fromMap(maps[i]),
    );
  }

  Future<int> updateNivelInspeccion(NivelInspeccion nivelInspeccion) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'NivelInspeccion',
      nivelInspeccion.toMap(),
      where: 'id = ?',
      whereArgs: [nivelInspeccion.id],
    );
  }

  Future<int> deleteNivelInspeccion(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'NivelInspeccion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}