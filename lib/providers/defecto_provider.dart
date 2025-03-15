import 'package:flutter/material.dart';
import '../models/defecto.dart';
import '../services/db/dao/defecto_dao.dart';

class DefectoProvider with ChangeNotifier {
  final DefectoDAO _defectoDAO = DefectoDAO();
  final List<Defecto> _defectos = [];

  List<Defecto> get defectos => List.unmodifiable(_defectos);

  // Cargar todos los defectoes desde la base de datos si aún no están en memoria
  Future<void> fetchDefectos() async {
    if (_defectos.isEmpty) {
      final defectosFromDb = await _defectoDAO.getDefectos();
      _defectos.addAll(defectosFromDb);
    }
    notifyListeners();
  }

  // Agregar un nuevo defecto y actualizar la memoria
  Future<void> addDefecto(Defecto defecto) async {
    await _defectoDAO.insertDefecto(defecto);
    _defectos.add(defecto);
    notifyListeners();
  }

  // Actualizar un defecto existente y reflejar el cambio en memoria
  Future<void> updateDefecto(Defecto defecto) async {
    if (defecto.id != null) {
      await _defectoDAO.updateDefecto(defecto);
      final index = _defectos.indexWhere((c) => c.id == defecto.id);
      if (index != -1) {
        _defectos[index] = defecto;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del defecto no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un defecto por su ID y actualizar la memoria
  Future<void> deleteDefecto(int id) async {
    await _defectoDAO.deleteDefecto(id);
    _defectos.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}