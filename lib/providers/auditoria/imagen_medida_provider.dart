import 'package:auditext/models/auditoria/imagen_medida.dart';
import 'package:auditext/services/db/dao/auditoria/imagen_medida_dao.dart';
import 'package:flutter/material.dart';

class ImagenMedidaProvider with ChangeNotifier {
  final ImagenMedidaDAO _ImagenMedidaDAO = ImagenMedidaDAO();
  final List<ImagenMedida> _ImagenMedidas = [];

  List<ImagenMedida> get ImagenMedidas => List.unmodifiable(_ImagenMedidas);

  // Cargar todos los ImagenMedidaes desde la base de datos si aún no están en memoria
  Future<void> fetchImagenMedidas() async {
    if (_ImagenMedidas.isEmpty) {
      final ImagenMedidasFromDb = await _ImagenMedidaDAO.getImagenMedidas();
      _ImagenMedidas.addAll(ImagenMedidasFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchImagenMedidaByElementoId(int elementoId) async {
    final imagesFromDb =
        await _ImagenMedidaDAO.getImagenMedidaByElementoId(elementoId);
    _ImagenMedidas.clear();
    _ImagenMedidas.addAll(imagesFromDb);
    notifyListeners();
  }

  // Agregar un nuevo ImagenMedida y actualizar la memoria
  Future<void> addImagenMedida(ImagenMedida ImagenMedida) async {
    final id = await _ImagenMedidaDAO.insertImagenMedida(ImagenMedida);
    ImagenMedida.id = id;
    _ImagenMedidas.add(ImagenMedida);
    notifyListeners();
  }

  // Actualizar un ImagenMedida existente y reflejar el cambio en memoria
  Future<void> updateImagenMedida(ImagenMedida ImagenMedida) async {
    if (ImagenMedida.id != null) {
      await _ImagenMedidaDAO.updateImagenMedida(ImagenMedida);
      final index = _ImagenMedidas.indexWhere((c) => c.id == ImagenMedida.id);
      if (index != -1) {
        _ImagenMedidas[index] = ImagenMedida;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID del ImagenMedida no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un ImagenMedida por su ID y actualizar la memoria
  Future<void> deleteImagenMedida(int id) async {
    await _ImagenMedidaDAO.deleteImagenMedida(id);
    _ImagenMedidas.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
