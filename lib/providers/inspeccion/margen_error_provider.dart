import 'package:auditext/models/inspeccion/margen_error.dart';
import 'package:auditext/services/db/dao/inspeccion/margen_error_dao.dart';
import 'package:flutter/material.dart';

class MargenErrorProvider with ChangeNotifier {
  final MargenErrorDAO _margenDAO = MargenErrorDAO();
  final List<MargenError> _margenes = [];

  List<MargenError> get margenes => List.unmodifiable(_margenes);

  // Cargar todas las margenes desde la base de datos si aún no están en memoria
  Future<void> fetchMargenErrores() async {
    if (_margenes.isEmpty) {
      final inspectionsFromDb = await _margenDAO.getMargenErrores();
      _margenes.addAll(inspectionsFromDb);
    }
    notifyListeners();
  }

  // Agregar una nueva inspección y actualizar la memoria
  Future<void> addMargenError(MargenError margen) async {
    await _margenDAO.insertMargenError(margen);
    _margenes.add(margen);
    notifyListeners();
  }

  // Actualizar una inspección existente y reflejar el cambio en memoria
  Future<void> updateMargenError(MargenError margen) async {
    if (margen.id != null) {
      await _margenDAO.updateMargenError(margen);
      final index = _margenes.indexWhere((i) => i.id == margen.id);
      if (index != -1) {
        _margenes[index] = margen;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID del margen de error no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una inspección por su ID y actualizar la memoria
  Future<void> deleteMargenError(int id) async {
    await _margenDAO.deleteMargenError(id);
    _margenes.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
