import '../../../../models/inspeccion/nqa.dart';
import '../../database_manager.dart';

class NqaDAO {
  Future<int> insertNqa(Nqa nqa) async {
    final db = await DatabaseManager().database;
    return await db.insert('Nqa', nqa.toMap());
  }

  Future<List<Nqa>> getNqas() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Nqa');
    return List.generate(
      maps.length,
          (i) => Nqa.fromMap(maps[i]),
    );
  }

  Future<int> updateNqa(Nqa nqa) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Nqa',
      nqa.toMap(),
      where: 'id = ?',
      whereArgs: [nqa.id],
    );
  }

  Future<int> deleteNqa(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Nqa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
