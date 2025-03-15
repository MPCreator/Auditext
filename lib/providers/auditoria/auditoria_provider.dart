import 'package:flutter/material.dart';

import '../../models/auditoria/auditoria.dart';
import '../../services/db/dao/auditoria/auditoria_dao.dart';

class AuditoriaProvider with ChangeNotifier {
  final AuditoriaDAO _auditoriaDAO = AuditoriaDAO();
  final List<Auditoria> _auditorias = [];

  List<Auditoria> get auditorias => List.unmodifiable(_auditorias);

  // Cargar todos los auditoriaes desde la base de datos si aún no están en memoria
  Future<void> fetchAuditorias() async {
    if (_auditorias.isEmpty) {
      final auditoriasFromDb = await _auditoriaDAO.getAuditorias();
      _auditorias.addAll(auditoriasFromDb);
    }
    notifyListeners();
  }

  // Agregar un nuevo auditoria y actualizar la memoria
  Future<int?> addAuditoria(Auditoria auditoria) async {
    final id = await _auditoriaDAO.insertAuditoria(auditoria);
    auditoria.id = id;
    _auditorias.add(auditoria);
    notifyListeners();
    return id;
  }



  // Actualizar un auditoria existente y reflejar el cambio en memoria
  Future<void> updateAuditoria(Auditoria auditoria) async {
    if (auditoria.id != null) {
      await _auditoriaDAO.updateAuditoria(auditoria);
      final index = _auditorias.indexWhere((c) => c.id == auditoria.id);
      if (index != -1) {
        _auditorias[index] = auditoria;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del auditoria no puede ser nulo para actualizar.");
    }
  }

  // Eliminar un auditoria por su ID y actualizar la memoria
  Future<void> deleteAuditoria(int id) async {
    await _auditoriaDAO.deleteAuditoria(id);
    _auditorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}