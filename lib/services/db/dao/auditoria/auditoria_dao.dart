import '../../../../models/auditoria/auditoria.dart';
import '../../database_manager.dart';

class AuditoriaDAO {
  Future<int> insertAuditoria(Auditoria auditoria) async {
    final db = await DatabaseManager().database;
    return await db.insert('Auditoria', auditoria.toMap());
  }

  Future<List<Auditoria>> getAuditorias() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Auditoria');
    return List.generate(
      maps.length,
          (i) => Auditoria.fromMap(maps[i]),
    );
  }

  Future<int> updateAuditoria(Auditoria auditoria) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Auditoria',
      auditoria.toMap(),
      where: 'id = ?',
      whereArgs: [auditoria.id],
    );
  }

  Future<int> deleteAuditoria(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Auditoria',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}