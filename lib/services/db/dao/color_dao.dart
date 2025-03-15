import '../database_manager.dart';
import '../../../models/color.dart';


class ColorDAO {
  Future<int> insertColor(Color color) async {
    final db = await DatabaseManager().database;
    return await db.insert('Color', color.toMap());
  }

  Future<List<Color>> getColors() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Color');
    return List.generate(
      maps.length,
          (i) => Color.fromMap(maps[i]),
    );
  }

  Future<int> updateColor(Color color) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Color',
      color.toMap(),
      where: 'id = ?',
      whereArgs: [color.id],
    );
  }

  Future<int> deleteColor(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Color',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
