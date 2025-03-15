import 'package:flutter/cupertino.dart';
import '../models/user_settings.dart';
import '../services/db/dao/user_settings_dao.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsDAO _settingsDAO = SettingsDAO();
  List<UserSettings> _settings = [];

  // Se expone una lista inmodificable
  List<UserSettings> get settings => List.unmodifiable(_settings);

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _settings = await _settingsDAO.getSettings();
    notifyListeners();
  }

  // Actualiza o agrega un settings en la lista y en la BD.
  Future<void> saveSettings(UserSettings settings) async {
    int index = _settings.indexWhere((s) => s.id == settings.id);
    if (index != -1) {
      _settings[index] = settings;
    } else {
      _settings.add(settings);
    }
    await _settingsDAO.updateSettings(settings);
    notifyListeners();
  }
}
