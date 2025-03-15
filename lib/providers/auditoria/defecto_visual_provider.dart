import 'package:flutter/material.dart';
import '../../models/auditoria/defecto_visual.dart';
import '../../services/db/dao/auditoria/defecto_visual_dao.dart';

class DefectoVisualProvider with ChangeNotifier {
  final DefectoVisualDAO _DefectoVisualDAO = DefectoVisualDAO();
  final List<DefectoVisual> _DefectoVisuals = [];

  List<DefectoVisual> get DefectoVisuals => List.unmodifiable(_DefectoVisuals);

  // Cargar todos los DefectoVisuales desde la base de datos si aún no están en memoria
  Future<void> fetchDefectoVisuals() async {
    if (_DefectoVisuals.isEmpty) {
      final DefectoVisualsFromDb = await _DefectoVisualDAO.getDefectoVisuals();
      _DefectoVisuals.addAll(DefectoVisualsFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchDefectoVisualByElementoId(int elementoId) async {
    final imagesFromDb = await _DefectoVisualDAO.getDefectoVisualByElementoId(elementoId);
    _DefectoVisuals.clear();
    _DefectoVisuals.addAll(imagesFromDb);
    notifyListeners();
  }
  
  // Agregar un nuevo DefectoVisual y actualizar la memoria
  Future<void> addDefectoVisual(DefectoVisual DefectoVisual) async {
    final id = await _DefectoVisualDAO.insertDefectoVisual(DefectoVisual);
    DefectoVisual.id = id;
    _DefectoVisuals.add(DefectoVisual);
    notifyListeners();
  }

  // Actualizar un DefectoVisual existente y reflejar el cambio en memoria
  Future<void> updateDefectoVisual(DefectoVisual DefectoVisual) async {
    if (DefectoVisual.id != null) {
      await _DefectoVisualDAO.updateDefectoVisual(DefectoVisual);
      final index = _DefectoVisuals.indexWhere((c) => c.id == DefectoVisual.id);
      if (index != -1) {
        _DefectoVisuals[index] = DefectoVisual;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del DefectoVisual no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un DefectoVisual por su ID y actualizar la memoria
  Future<void> deleteDefectoVisual(int id) async {
    await _DefectoVisualDAO.deleteDefectoVisual(id);
    _DefectoVisuals.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}