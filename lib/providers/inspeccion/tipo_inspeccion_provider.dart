import 'package:flutter/material.dart';
import '../../models/inspeccion/tipo_inspeccion.dart';
import '../../services/db/dao/inspeccion/tipo_inspeccion_dao.dart';

class TipoInspeccionProvider with ChangeNotifier {
  final TipoInspeccionDAO _tipoInspeccionDAO = TipoInspeccionDAO();
  final List<TipoInspeccion> _tipoInspecciones = [];

  List<TipoInspeccion> get tipoInspecciones => List.unmodifiable(_tipoInspecciones);

  Future<void> fetchTipoInspecciones() async {
    if (_tipoInspecciones.isEmpty) {
      final tiposFromDb = await _tipoInspeccionDAO.getTipoInspecciones();
      _tipoInspecciones.addAll(tiposFromDb);
    }
    notifyListeners();
  }

  Future<void> addTipoInspeccion(TipoInspeccion tipoInspeccion) async {
    await _tipoInspeccionDAO.insertTipoInspeccion(tipoInspeccion);
    _tipoInspecciones.add(tipoInspeccion);
    notifyListeners();
  }

  Future<void> updateTipoInspeccion(TipoInspeccion tipoInspeccion) async {
    if (tipoInspeccion.id != null) {
      await _tipoInspeccionDAO.updateTipoInspeccion(tipoInspeccion);
      final index = _tipoInspecciones.indexWhere((t) => t.id == tipoInspeccion.id);
      if (index != -1) {
        _tipoInspecciones[index] = tipoInspeccion;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del tipo de inspección no puede ser nulo para actualizar.");
    }
  }

  Future<void> deleteTipoInspeccion(int id) async {
    await _tipoInspeccionDAO.deleteTipoInspeccion(id);
    _tipoInspecciones.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
