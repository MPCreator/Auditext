import 'package:flutter/material.dart';
import '../models/color.dart';
import '../services/db/dao/color_dao.dart';

class ColorProvider with ChangeNotifier {
  final ColorDAO _colorDAO = ColorDAO();
  final List<Color> _colors = [];

  List<Color> get colors => List.unmodifiable(_colors);

  // Cargar todos los colores desde la base de datos si aún no están en memoria
  Future<void> fetchColors() async {
    if (_colors.isEmpty) {
      final colorsFromDb = await _colorDAO.getColors();
      _colors.addAll(colorsFromDb);
    }
    notifyListeners();
  }

  // Agregar un nuevo color y actualizar la memoria
  Future<void> addColor(Color color) async {
    await _colorDAO.insertColor(color);
    _colors.add(color);
    notifyListeners();
  }

  // Actualizar un color existente y reflejar el cambio en memoria
  Future<void> updateColor(Color color) async {
    if (color.id != null) {
      await _colorDAO.updateColor(color);
      final index = _colors.indexWhere((c) => c.id == color.id);
      if (index != -1) {
        _colors[index] = color;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del color no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un color por su ID y actualizar la memoria
  Future<void> deleteColor(int id) async {
    await _colorDAO.deleteColor(id);
    _colors.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}