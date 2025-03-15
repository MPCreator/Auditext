import 'package:auditext/models/auditoria/imagen_visual.dart';
import '../../database_manager.dart';

class ImagenVisualDAO {
  Future<int> insertImagenVisual(ImagenVisual ImagenVisual) async {
    final db = await DatabaseManager().database;
    return await db.insert('ImagenVisual', ImagenVisual.toMap());
  }

  Future<List<ImagenVisual>> getImagenVisuals() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('ImagenVisual');
    return List.generate(
      maps.length,
      (i) => ImagenVisual.fromMap(maps[i]),
    );
  }

  Future<List<ImagenVisual>> getImagenVisualByElementoId(int elementoId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ImagenVisual',
      where: 'elementoId = ?',
      whereArgs: [elementoId],
    );
    return List.generate(
      maps.length,
      (i) => ImagenVisual.fromMap(maps[i]),
    );
  }

  Future<int> updateImagenVisual(ImagenVisual ImagenVisual) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'ImagenVisual',
      ImagenVisual.toMap(),
      where: 'id = ?',
      whereArgs: [ImagenVisual.id],
    );
  }

  Future<int> deleteImagenVisual(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'ImagenVisual',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
