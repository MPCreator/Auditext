import 'package:flutter/material.dart';

import '../../models/auditoria/analisis_dimensional.dart';
import '../../services/db/dao/auditoria/analisis_dimensional_dao.dart';

class AnalisisDimensionalProvider with ChangeNotifier {
  final AnalisisDimensionalDAO _AnalisisDimensionalDAO =
      AnalisisDimensionalDAO();
  final List<AnalisisDimensional> _AnalisisDimensionals = [];

  List<AnalisisDimensional> get AnalisisDimensionals =>
      List.unmodifiable(_AnalisisDimensionals);

  // Cargar todos los AnalisisDimensionales desde la base de datos si aún no están en memoria
  Future<void> fetchAnalisisDimensionals() async {
    if (_AnalisisDimensionals.isEmpty) {
      final AnalisisDimensionalsFromDb =
          await _AnalisisDimensionalDAO.getAnalisisDimensionals();
      _AnalisisDimensionals.addAll(AnalisisDimensionalsFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchAnalisisDimensionalByElementoId(int elementoId) async {
    final imagesFromDb =
        await _AnalisisDimensionalDAO.getAnalisisDimensionalByElementoId(
            elementoId);
    _AnalisisDimensionals.clear();
    _AnalisisDimensionals.addAll(imagesFromDb);
    notifyListeners();
  }

  // Agregar un nuevo AnalisisDimensional y actualizar la memoria
  Future<int?> addAnalisisDimensional(
      AnalisisDimensional analisisDimensional) async {
    final id = await _AnalisisDimensionalDAO.insertAnalisisDimensional(
        analisisDimensional);
    analisisDimensional.id = id;
    _AnalisisDimensionals.add(analisisDimensional);
    notifyListeners();
    return id;
  }

  // Actualizar un AnalisisDimensional existente y reflejar el cambio en memoria
  Future<void> updateAnalisisDimensional(
      AnalisisDimensional AnalisisDimensional) async {
    if (AnalisisDimensional.id != null) {
      await _AnalisisDimensionalDAO.updateAnalisisDimensional(
          AnalisisDimensional);
      final index = _AnalisisDimensionals.indexWhere(
          (c) => c.id == AnalisisDimensional.id);
      if (index != -1) {
        _AnalisisDimensionals[index] = AnalisisDimensional;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID del AnalisisDimensional no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un AnalisisDimensional por su ID y actualizar la memoria
  Future<void> deleteAnalisisDimensional(int id) async {
    await _AnalisisDimensionalDAO.deleteAnalisisDimensional(id);
    _AnalisisDimensionals.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
