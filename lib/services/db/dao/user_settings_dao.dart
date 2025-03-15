import 'package:sqflite/sqflite.dart';
import '../../../models/user_settings.dart';
import '../database_manager.dart';

class SettingsDAO {
  // Retorna una lista de settings en lugar de uno solo.
  Future<List<UserSettings>> getSettings() async {
    final db = await DatabaseManager().database;
    final result = await db.query('UserSettings');
    if (result.isNotEmpty) {
      return result.map((map) => UserSettings.fromMap(map)).toList();
    }
    return [];
  }

  Future<void> updateSettings(UserSettings settings) async {
    final db = await DatabaseManager().database;
    await db.insert(
      'UserSettings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
