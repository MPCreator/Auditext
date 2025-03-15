import 'package:flutter/material.dart';
import '../models/talla.dart';
import '../services/db/dao/talla_dao.dart';

class TallaProvider with ChangeNotifier {
  final TallaDAO _tallaDAO = TallaDAO();
  final List<Talla> _tallas = [];

  List<Talla> get tallas => List.unmodifiable(_tallas);

  // Cargar todos las tallas desde la base de datos si aún no están en memoria
  Future<void> fetchTallas() async {
    if (_tallas.isEmpty) {
      final tallasFromDb = await _tallaDAO.getTallas();
      _tallas.addAll(tallasFromDb);
    }
    notifyListeners();
  }

  // Agregar una nueva talla y actualizar la memoria
  Future<void> addTalla(Talla talla) async {
    await _tallaDAO.insertTalla(talla);
    _tallas.add(talla);
    notifyListeners();
  }

  // Actualizar una talla existente y reflejar el cambio en memoria
  Future<void> updateTalla(Talla talla) async {
    if (talla.id != null) {
      await _tallaDAO.updateTalla(talla);
      final index = _tallas.indexWhere((t) => t.id == talla.id);
      if (index != -1) {
        _tallas[index] = talla;
        notifyListeners();
      }
    } else {
      throw Exception("El ID de la talla no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una talla por su ID y actualizar la memoria
  Future<void> deleteTalla(int id) async {
    await _tallaDAO.deleteTalla(id);
    _tallas.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
