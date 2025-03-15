import 'package:flutter/material.dart';
import '../../models/inspeccion/nivel_inspeccion.dart';
import '../../services/db/dao/inspeccion/nivel_inspeccion_Dao.dart';

class NivelInspeccionProvider with ChangeNotifier {
  final NivelInspeccionDAO _nivelInspeccionDAO = NivelInspeccionDAO();
  final List<NivelInspeccion> _nivelInspecciones = [];

  List<NivelInspeccion> get nivelInspecciones => List.unmodifiable(_nivelInspecciones);


  Future<void> fetchNivelInspecciones() async {
    if (_nivelInspecciones.isEmpty) {
      final nivelesFromDb = await _nivelInspeccionDAO.getNivelInspecciones();
      _nivelInspecciones.addAll(nivelesFromDb);
    }
    notifyListeners();
  }

  Future<void> addNivelInspeccion(NivelInspeccion nivelInspeccion) async {
    await _nivelInspeccionDAO.insertNivelInspeccion(nivelInspeccion);
    _nivelInspecciones.add(nivelInspeccion);
    notifyListeners();
  }

  Future<void> updateNivelInspeccion(NivelInspeccion nivelInspeccion) async {
    if (nivelInspeccion.id != null) {
      await _nivelInspeccionDAO.updateNivelInspeccion(nivelInspeccion);
      final index = _nivelInspecciones.indexWhere((n) => n.id == nivelInspeccion.id);
      if (index != -1) {
        _nivelInspecciones[index] = nivelInspeccion;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del nivel de inspección no puede ser nulo para actualizar.");
    }
  }

  Future<void> deleteNivelInspeccion(int id) async {
    await _nivelInspeccionDAO.deleteNivelInspeccion(id);
    _nivelInspecciones.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
