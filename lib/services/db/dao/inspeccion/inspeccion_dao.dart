import '../../../../models/inspeccion/inspeccion.dart';
import '../../database_manager.dart';

class InspeccionDAO {
  Future<int> insertInspeccion(Inspeccion inspeccion) async {
    final db = await DatabaseManager().database;
    return await db.insert('Inspeccion', inspeccion.toMap());
  }

  Future<List<Inspeccion>> getInspecciones() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Inspeccion');
    return List.generate(
      maps.length,
      (i) => Inspeccion.fromMap(maps[i]),
    );
  }

  Future<List<Inspeccion>> getInspeccionesByAllCriteria({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required String tamanoLote,
  }) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Inspeccion',
      where:
          'nqaId = ? AND tipoInspeccionId = ? AND nivelInspeccionId = ? AND tamanoLote = ?',
      whereArgs: [nqaId, tipoInspeccionId, nivelInspeccionId, tamanoLote],
    );
    return List.generate(maps.length, (i) {
      return Inspeccion.fromMap(maps[i]);
    });
  }

  /// Método optimizado: obtiene inspecciones filtrando por
  /// nqaId, tipoInspeccionId y nivelInspeccionId.
  Future<List<Inspeccion>> getInspeccionesByCriteria({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
  }) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Inspeccion',
      where: 'nqaId = ? AND tipoInspeccionId = ? AND nivelInspeccionId = ?',
      whereArgs: [nqaId, tipoInspeccionId, nivelInspeccionId],
    );
    return List.generate(
      maps.length,
      (i) => Inspeccion.fromMap(maps[i]),
    );
  }

  Future<int> updateInspeccion(Inspeccion inspeccion) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Inspeccion',
      inspeccion.toMap(),
      where: 'id = ?',
      whereArgs: [inspeccion.id],
    );
  }

  Future<int> deleteInspeccion(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Inspeccion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
