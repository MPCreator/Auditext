import 'package:flutter/material.dart';
import '../../models/inspeccion/inspeccion.dart';
import '../../services/db/dao/inspeccion/inspeccion_dao.dart';

class InspeccionProvider with ChangeNotifier {
  final InspeccionDAO _inspeccionDAO = InspeccionDAO();
  final List<Inspeccion> _inspecciones = [];

  List<Inspeccion> get inspecciones => List.unmodifiable(_inspecciones);

  // Cargar todas las inspecciones desde la base de datos si aún no están en memoria
  Future<void> fetchInspecciones() async {
    if (_inspecciones.isEmpty) {
      final inspectionsFromDb = await _inspeccionDAO.getInspecciones();
      _inspecciones.addAll(inspectionsFromDb);
    }
    notifyListeners();
  }

  // Agregar una nueva inspección y actualizar la memoria
  Future<void> addInspeccion(Inspeccion inspeccion) async {
    await _inspeccionDAO.insertInspeccion(inspeccion);
    _inspecciones.add(inspeccion);
    notifyListeners();
  }

  // Actualizar una inspección existente y reflejar el cambio en memoria
  Future<void> updateInspeccion(Inspeccion inspeccion) async {
    if (inspeccion.id != null) {
      await _inspeccionDAO.updateInspeccion(inspeccion);
      final index = _inspecciones.indexWhere((i) => i.id == inspeccion.id);
      if (index != -1) {
        _inspecciones[index] = inspeccion;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID de la inspección no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una inspección por su ID y actualizar la memoria
  Future<void> deleteInspeccion(int id) async {
    await _inspeccionDAO.deleteInspeccion(id);
    _inspecciones.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// Obtiene la primera inspección que cumpla con los criterios especificados.
  Future<Inspeccion?> fetchInspeccionForTotalGeneral({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required int totalGeneral,
  }) async {
    // Se consultan todas las inspecciones para la combinación dada.
    final inspecciones = await _inspeccionDAO.getInspeccionesByCriteria(
      nqaId: nqaId,
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
    );

    // Se recorre cada registro para determinar si totalGeneral se encuentra en el rango.
    for (final inspeccion in inspecciones) {
      final rango =
          inspeccion.tamanoLote; // Ej.: "2-8", "51-90", "500000<", etc.

      if (rango.contains('-')) {
        // Si el rango es del tipo "min-max"
        final partes = rango.split('-');
        if (partes.length == 2) {
          final int? min = int.tryParse(partes[0].trim());
          final int? max = int.tryParse(partes[1].trim());
          if (min != null && max != null) {
            if (totalGeneral >= min && totalGeneral <= max) {
              return inspeccion;
            }
          }
        }
      } else if (rango.contains('<')) {
        // Si el rango es del tipo "500000<" (se asume que es: totalGeneral >= 500000)
        final String numStr = rango.replaceAll('<', '').trim();
        final int? min = int.tryParse(numStr);
        if (min != null && totalGeneral >= min) {
          return inspeccion;
        }
      }
    }
    return null;
  }

  /// Método optimizado: obtiene inspecciones filtradas por los parámetros básicos.
  Future<List<Inspeccion>> fetchInspeccionesByCriteria({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
  }) async {
    return await _inspeccionDAO.getInspeccionesByCriteria(
      nqaId: nqaId,
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
    );
  }
}
