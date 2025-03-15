import 'package:flutter/material.dart';
import '../../models/inspeccion/nqa.dart';
import '../../services/db/dao/inspeccion/nqa_dao.dart';

class NqaProvider with ChangeNotifier {
  final NqaDAO _nqaDAO = NqaDAO();
  final List<Nqa> _nqas = [];

  List<Nqa> get nqas => List.unmodifiable(_nqas);

  Future<void> fetchNqas() async {
    if (_nqas.isEmpty) {
      final nqasFromDb = await _nqaDAO.getNqas();
      _nqas.addAll(nqasFromDb);
    }
    notifyListeners();
  }

  Future<void> addNqa(Nqa nqa) async {
    await _nqaDAO.insertNqa(nqa);
    _nqas.add(nqa);
    notifyListeners();
  }

  Future<void> updateNqa(Nqa nqa) async {
    if (nqa.id != null) {
      await _nqaDAO.updateNqa(nqa);
      final index = _nqas.indexWhere((n) => n.id == nqa.id);
      if (index != -1) {
        _nqas[index] = nqa;
        notifyListeners();
      }
    } else {
      throw Exception("El ID del NQA no puede ser nulo para actualizar.");
    }
  }

  Future<void> deleteNqa(int id) async {
    await _nqaDAO.deleteNqa(id);
    _nqas.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}