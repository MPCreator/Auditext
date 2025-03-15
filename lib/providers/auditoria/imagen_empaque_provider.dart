import 'package:flutter/material.dart';
import '../../models/auditoria/imagen_empaque.dart';
import '../../services/db/dao/auditoria/imagen_empaque_dao.dart';


class ImagenEmpaqueProvider with ChangeNotifier {
  final ImagenEmpaqueDAO _ImagenEmpaqueDAO = ImagenEmpaqueDAO();
  final List<ImagenEmpaque> _ImagenEmpaques = [];

  List<ImagenEmpaque> get ImagenEmpaques => List.unmodifiable(_ImagenEmpaques);

  // Cargar todos los ImagenEmpaquees desde la base de datos si aún no están en memoria
  Future<void> fetchImagenEmpaques() async {
    if (_ImagenEmpaques.isEmpty) {
      final ImagenEmpaquesFromDb = await _ImagenEmpaqueDAO.getImagenEmpaques();
      _ImagenEmpaques.addAll(ImagenEmpaquesFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchImagenEmpaqueByElementoId(int elementoId) async {
    final imagesFromDb = await _ImagenEmpaqueDAO.getImagenEmpaqueByElementoId(elementoId);
    _ImagenEmpaques.clear();
    _ImagenEmpaques.addAll(imagesFromDb);
    notifyListeners();
  }

  // Agregar un nuevo ImagenEmpaque y actualizar la memoria
  Future<void> addImagenEmpaque(ImagenEmpaque ImagenEmpaque) async {
    final id = await _ImagenEmpaqueDAO.insertImagenEmpaque(ImagenEmpaque);
    ImagenEmpaque.id = id;
    _ImagenEmpaques.add(ImagenEmpaque);
    notifyListeners();
  }

  // Actualizar un ImagenEmpaque existente y reflejar el cambio en memoria
  Future<void> updateImagenEmpaque(ImagenEmpaque ImagenEmpaque) async {
    if (ImagenEmpaque.id != null) {
      await _ImagenEmpaqueDAO.updateImagenEmpaque(ImagenEmpaque);
      final index = _ImagenEmpaques.indexWhere((c) => c.id == ImagenEmpaque.id);
      if (index != -1) {
        _ImagenEmpaques[index] = ImagenEmpaque;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del ImagenEmpaque no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un ImagenEmpaque por su ID y actualizar la memoria
  Future<void> deleteImagenEmpaque(int id) async {
    await _ImagenEmpaqueDAO.deleteImagenEmpaque(id);
    _ImagenEmpaques.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}