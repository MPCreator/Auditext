import '../database_manager.dart';
import '../../../models/defecto.dart';


class DefectoDAO {
  Future<int> insertDefecto(Defecto defecto) async {
    final db = await DatabaseManager().database;
    return await db.insert('Defecto', defecto.toMap());
  }

  Future<List<Defecto>> getDefectos() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Defecto');
    return List.generate(
      maps.length,
          (i) => Defecto.fromMap(maps[i]),
    );
  }

  Future<int> updateDefecto(Defecto defecto) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Defecto',
      defecto.toMap(),
      where: 'id = ?',
      whereArgs: [defecto.id],
    );
  }

  Future<int> deleteDefecto(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Defecto',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
