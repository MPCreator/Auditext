import 'package:flutter/material.dart';

import '../../models/auditoria/elemento.dart';
import '../../services/db/dao/auditoria/elemento_dao.dart';

class ElementoProvider with ChangeNotifier {
  final ElementoDAO _elementoDAO = ElementoDAO();
  final List<Elemento> _elementos = [];

  List<Elemento> get elementos => List.unmodifiable(_elementos);

  // Cargar todos los elementoes desde la base de datos si aún no están en memoria
  Future<void> fetchElementos() async {
    if (_elementos.isEmpty) {
      final elementosFromDb = await _elementoDAO.getElementos();
      _elementos.addAll(elementosFromDb);
    }
    notifyListeners();
  }

  Future<void> fetchElementosByAuditoriaId(int auditoriaId) async {
    final elementosFromDb = await _elementoDAO.getElementosByAuditoriaId(auditoriaId);
    _elementos.clear(); //Carga solo los elementos de la auditoria actual
    _elementos.addAll(elementosFromDb);
    notifyListeners();
  }


  // Agregar un nuevo elemento y actualizar la memoria
  Future<void> addElemento(Elemento elemento) async {
    final id = await _elementoDAO.insertElemento(elemento);
    elemento.id = id;
    _elementos.add(elemento);
    notifyListeners();
  }

  // Actualizar un elemento existente y reflejar el cambio en memoria
  Future<void> updateElemento(Elemento elemento) async {
    if (elemento.id != null) {
      await _elementoDAO.updateElemento(elemento);
      final index = _elementos.indexWhere((c) => c.id == elemento.id);
      if (index != -1) {
        _elementos[index] = elemento;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del elemento no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un elemento por su ID y actualizar la memoria
  Future<void> deleteElemento(int id) async {
    await _elementoDAO.deleteElemento(id);
    _elementos.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}