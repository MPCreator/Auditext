import '../../../../models/auditoria/defecto_visual.dart';
import '../../database_manager.dart';

class DefectoVisualDAO {
  Future<int> insertDefectoVisual(DefectoVisual DefectoVisual) async {
    final db = await DatabaseManager().database;
    return await db.insert('DefectoVisual', DefectoVisual.toMap());
  }

  Future<List<DefectoVisual>> getDefectoVisuals() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('DefectoVisual');
    return List.generate(
      maps.length,
          (i) => DefectoVisual.fromMap(maps[i]),
    );
  }

  Future<List<DefectoVisual>> getDefectoVisualByElementoId(int elementoId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DefectoVisual',
      where: 'elementoId = ?',
      whereArgs: [elementoId],
    );
    return List.generate(
      maps.length,
          (i) => DefectoVisual.fromMap(maps[i]),
    );
  }

  Future<int> updateDefectoVisual(DefectoVisual DefectoVisual) async {
    final db = await DatabaseManager().database;
    print('Actualizando DefectoVisual con ID: ${DefectoVisual.id}');

    return await db.update(
      'DefectoVisual',
      DefectoVisual.toMap(),
      where: 'id = ?',
      whereArgs: [DefectoVisual.id],
    );
  }

  Future<int> deleteDefectoVisual(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'DefectoVisual',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}