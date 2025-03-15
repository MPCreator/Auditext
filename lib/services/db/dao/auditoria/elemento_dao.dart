import '../../../../models/auditoria/elemento.dart';
import '../../database_manager.dart';

class ElementoDAO {
  Future<int> insertElemento(Elemento Elemento) async {
    final db = await DatabaseManager().database;
    return await db.insert('Elemento', Elemento.toMap());
  }

  Future<List<Elemento>> getElementos() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Elemento');
    return List.generate(
      maps.length,
          (i) => Elemento.fromMap(maps[i]),
    );
  }

  Future<Elemento> getElementoById(int elementoId) async {
    final db = await DatabaseManager().database;

    final maps = await db.query(
      'Elemento',
      where: 'id = ?',
      whereArgs: [elementoId],
    );
    return Elemento.fromMap(maps.first);
  }

  Future<List<Elemento>> getElementosByAuditoriaId(int auditoriaId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Elemento',
      where: 'auditoriaId = ?',
      whereArgs: [auditoriaId],
    );
    return List.generate(
      maps.length,
          (i) => Elemento.fromMap(maps[i]),
    );
  }


  Future<int> updateElemento(Elemento Elemento) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Elemento',
      Elemento.toMap(),
      where: 'id = ?',
      whereArgs: [Elemento.id],
    );
  }

  Future<int> deleteElemento(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Elemento',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}