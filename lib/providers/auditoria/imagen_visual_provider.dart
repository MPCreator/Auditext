import 'package:auditext/models/auditoria/imagen_visual.dart';
import 'package:flutter/material.dart';
import '../../services/db/dao/auditoria/imagen_visual_dao.dart';

class ImagenVisualProvider with ChangeNotifier {
  final ImagenVisualDAO _ImagenVisualDAO = ImagenVisualDAO();
  final List<ImagenVisual> _ImagenVisuals = [];

  List<ImagenVisual> get ImagenVisuals => List.unmodifiable(_ImagenVisuals);

  // Cargar todos los ImagenVisuales desde la base de datos si aún no están en memoria
  Future<void> fetchImagenVisuals() async {
    if (_ImagenVisuals.isEmpty) {
      final ImagenVisualsFromDb = await _ImagenVisualDAO.getImagenVisuals();
      _ImagenVisuals.addAll(ImagenVisualsFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchImagenVisualByElementoId(int elementoId) async {
    final imagesFromDb =
        await _ImagenVisualDAO.getImagenVisualByElementoId(elementoId);
    _ImagenVisuals.clear();
    _ImagenVisuals.addAll(imagesFromDb);
    notifyListeners();
  }

  // Agregar un nuevo ImagenVisual y actualizar la memoria
  Future<void> addImagenVisual(ImagenVisual ImagenVisual) async {
    final id = await _ImagenVisualDAO.insertImagenVisual(ImagenVisual);
    ImagenVisual.id = id;
    _ImagenVisuals.add(ImagenVisual);
    notifyListeners();
  }

  // Actualizar un ImagenVisual existente y reflejar el cambio en memoria
  Future<void> updateImagenVisual(ImagenVisual ImagenVisual) async {
    if (ImagenVisual.id != null) {
      await _ImagenVisualDAO.updateImagenVisual(ImagenVisual);
      final index = _ImagenVisuals.indexWhere((c) => c.id == ImagenVisual.id);
      if (index != -1) {
        _ImagenVisuals[index] = ImagenVisual;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID del ImagenVisual no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un ImagenVisual por su ID y actualizar la memoria
  Future<void> deleteImagenVisual(int id) async {
    await _ImagenVisualDAO.deleteImagenVisual(id);
    _ImagenVisuals.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
