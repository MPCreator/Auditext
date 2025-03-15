import '../../../../models/inspeccion/tipo_inspeccion.dart';
import '../../database_manager.dart';

class TipoInspeccionDAO {
  Future<int> insertTipoInspeccion(TipoInspeccion tipoInspeccion) async {
    final db = await DatabaseManager().database;
    return await db.insert('TipoInspeccion', tipoInspeccion.toMap());
  }

  Future<List<TipoInspeccion>> getTipoInspecciones() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('TipoInspeccion');
    return List.generate(
      maps.length,
          (i) => TipoInspeccion.fromMap(maps[i]),
    );
  }


  Future<int> updateTipoInspeccion(TipoInspeccion tipoInspeccion) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'TipoInspeccion',
      tipoInspeccion.toMap(),
      where: 'id = ?',
      whereArgs: [tipoInspeccion.id],
    );
  }

  Future<int> deleteTipoInspeccion(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'TipoInspeccion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

