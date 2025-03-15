import 'package:flutter/material.dart';
import '../models/descripcion.dart';
import '../services/db/dao/descripcion_dao.dart';

class DescripcionProvider with ChangeNotifier {
  final DescripcionDao _descripcionDAO = DescripcionDao();
  final List<Descripcion> _descripciones = [];

  List<Descripcion> get descripciones => List.unmodifiable(_descripciones);

  // Cargar todos las descripciones desde la base de datos si aún no están en memoria
  Future<void> fetchDescripcions() async {
    _descripciones.clear();
    final descripcionesFromDb = await _descripcionDAO.getAll();
    _descripciones.addAll(descripcionesFromDb);
    notifyListeners();
  }

  // Función que genera el mapping: nombre de descripción -> ID (en String)
  Future<Map<String, String>> getDescripcionMapping() async {
    // Asegurarse de que las descripciones estén cargadas
    if (_descripciones.isEmpty) {
      await fetchDescripcions();
    }
    final Map<String, String> mapping = {};
    for (var desc in _descripciones) {
      // Se asume que 'desc.descripcion' es el nombre y 'desc.id' es el identificador
      mapping[desc.descripcion] = desc.id.toString();
    }
    return mapping;
  }

  // Agregar una nueva descripcion y actualizar la memoria
  Future<void> addDescripcion(Descripcion descripcion) async {
    await _descripcionDAO.insert(descripcion);
    _descripciones.add(descripcion);
    notifyListeners();
  }

  // Actualizar una descripcion existente y reflejar el cambio en memoria
  Future<void> updateDescripcion(Descripcion descripcion) async {
    if (descripcion.id != null) {
      await _descripcionDAO.update(descripcion);
      final index = _descripciones.indexWhere((t) => t.id == descripcion.id);
      if (index != -1) {
        _descripciones[index] = descripcion;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID de la descripcion no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una descripcion por su ID y actualizar la memoria
  Future<void> deleteDescripcion(int id) async {
    await _descripcionDAO.delete(id);
    _descripciones.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
