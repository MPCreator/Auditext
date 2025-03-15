import 'package:auditext/models/auditoria/imagen_medida.dart';

import '../../database_manager.dart';

class ImagenMedidaDAO {
  Future<int> insertImagenMedida(ImagenMedida ImagenMedida) async {
    final db = await DatabaseManager().database;
    return await db.insert('ImagenMedida', ImagenMedida.toMap());
  }

  Future<List<ImagenMedida>> getImagenMedidas() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('ImagenMedida');
    return List.generate(
      maps.length,
      (i) => ImagenMedida.fromMap(maps[i]),
    );
  }

  Future<List<ImagenMedida>> getImagenMedidaByElementoId(int elementoId) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ImagenMedida',
      where: 'elementoId = ?',
      whereArgs: [elementoId],
    );
    return List.generate(
      maps.length,
      (i) => ImagenMedida.fromMap(maps[i]),
    );
  }

  Future<int> updateImagenMedida(ImagenMedida ImagenMedida) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'ImagenMedida',
      ImagenMedida.toMap(),
      where: 'id = ?',
      whereArgs: [ImagenMedida.id],
    );
  }

  Future<int> deleteImagenMedida(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'ImagenMedida',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
