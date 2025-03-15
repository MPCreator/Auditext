import '../../../../models/auditoria/imagen_empaque.dart';
import '../../database_manager.dart';

class ImagenEmpaqueDAO {
  Future<int> insertImagenEmpaque(ImagenEmpaque ImagenEmpaque) async {
    final db = await DatabaseManager().database;
    return await db.insert('ImagenEmpaque', ImagenEmpaque.toMap());
  }

  Future<List<ImagenEmpaque>> getImagenEmpaques() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('ImagenEmpaque');
    return List.generate(
      maps.length,
          (i) => ImagenEmpaque.fromMap(maps[i]),
    );
  }

  Future<List<ImagenEmpaque>> getImagenEmpaqueByElementoId(int elementoId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ImagenEmpaque',
      where: 'elementoId = ?',
      whereArgs: [elementoId],
    );
    return List.generate(
      maps.length,
          (i) => ImagenEmpaque.fromMap(maps[i]),
    );
  }

  Future<int> updateImagenEmpaque(ImagenEmpaque ImagenEmpaque) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'ImagenEmpaque',
      ImagenEmpaque.toMap(),
      where: 'id = ?',
      whereArgs: [ImagenEmpaque.id],
    );
  }

  Future<int> deleteImagenEmpaque(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'ImagenEmpaque',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}