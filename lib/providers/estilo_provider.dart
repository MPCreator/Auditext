import 'package:auditext/providers/tolerancia_provider.dart';
import 'package:flutter/material.dart';
import '../models/estilo.dart';
import '../services/db/dao/estilo_dao.dart';

class EstiloProvider with ChangeNotifier {
  final EstiloDao _estiloDAO = EstiloDao();
  final List<Estilo> _estilos = [];

  List<Estilo> get estilos => List.unmodifiable(_estilos);

  // Cargar todos las estilos desde la base de datos si aún no están en memoria
  Future<void> fetchEstilos() async {
    if (_estilos.isEmpty) {
      final estilosFromDb = await _estiloDAO.getEstilos();
      _estilos.addAll(estilosFromDb);
    }
    notifyListeners();
  }

  Future<int?> getEstiloIdByNombre(String nombre) async {
    return await _estiloDAO.getEstiloIdByName(nombre);
  }

  Future<Map<String, Map<String, double>>?> getToleranciaByEstiloNombre(
      String nombre) async {
    final int? estiloId = await _estiloDAO.getEstiloIdByName(nombre);
    if (estiloId == null) return null;

    final toleranciaProvider = ToleranciaProvider();
    final Map<String, dynamic>? toleranciaData =
        await toleranciaProvider.getToleranciaByEstiloId(estiloId);
    if (toleranciaData == null) return null;

    Map<String, Map<String, double>> toleranciaFormateada = {};
    toleranciaData.forEach((descId, tallas) {
      toleranciaFormateada[descId] = Map<String, double>.from(tallas);
    });

    return toleranciaFormateada;
  }

  Future<List<String>> getDescripcionesByEstiloNombre(String nombre) async {
    final int? estiloId = await _estiloDAO.getEstiloIdByName(nombre);
    if (estiloId == null) return [];
    final toleranciaProvider = ToleranciaProvider();
    final Map<String, dynamic>? toleranciaData =
        await toleranciaProvider.getToleranciaByEstiloId(estiloId);
    if (toleranciaData == null) return [];

    return toleranciaData.keys.toList();
  }

  // Agregar una nueva estilo y actualizar la memoria
  Future<void> addEstilo(Estilo estilo) async {
    await _estiloDAO.insertEstilo(estilo);
    _estilos.add(estilo);
    notifyListeners();
  }

  // Actualizar una estilo existente y reflejar el cambio en memoria
  Future<void> updateEstilo(Estilo estilo) async {
    if (estilo.id != null) {
      await _estiloDAO.updateEstilo(estilo);
      final index = _estilos.indexWhere((t) => t.id == estilo.id);
      if (index != -1) {
        _estilos[index] = estilo;
        notifyListeners();
      }
    } else {
      throw Exception("El ID de la estilo no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una estilo por su ID y actualizar la memoria
  Future<void> deleteEstilo(int id) async {
    await _estiloDAO.deleteEstilo(id);
    _estilos.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
