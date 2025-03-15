import '../../../models/talla.dart';
import '../database_manager.dart';

class TallaDAO {
  Future<int> insertTalla(Talla talla) async {
    final db = await DatabaseManager().database;
    return await db.insert('Talla', talla.toMap());
  }

  Future<List<Talla>> getTallas() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Talla');
    return List.generate(
      maps.length,
          (i) => Talla.fromMap(maps[i]),
    );
  }

  Future<int> updateTalla(Talla talla) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Talla',
      talla.toMap(),
      where: 'id = ?',
      whereArgs: [talla.id],
    );
  }

  Future<int> deleteTalla(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Talla',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
