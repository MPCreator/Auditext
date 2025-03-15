import 'dart:convert';

import '../../../models/tolerancia.dart';
import '../database_manager.dart';

class ToleranciaDao {
  Future<int> insertTolerancia(Tolerancia tolerancia) async {
    final db = await DatabaseManager().database;
    return await db.insert('Tolerancia', tolerancia.toMap());
  }

  Future<List<Tolerancia>> getTolerancias() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('Tolerancia');
    return List.generate(
      maps.length,
      (i) => Tolerancia.fromMap(maps[i]),
    );
  }

  Future<Map<String, dynamic>?> getToleranciaByEstiloId(int idEstilo) async {
    final db = await DatabaseManager().database;

    // Obtener la fila con los datos de tolerancia
    final result = await db.query(
      'Tolerancia',
      columns: ['datos'],
      where: 'id_estilo = ?',
      whereArgs: [idEstilo],
    );

    if (result.isEmpty) return null;

    // Convertir la columna 'datos' de JSON a un Map
    final datosJson = result.first['datos'] as String?;
    if (datosJson == null) return null; // Manejo de posible null

    Map<String, dynamic> datos = jsonDecode(datosJson);

    // Obtener los IDs de las descripciones únicas
    Set<int> descripcionIds = {};
    datos.values.forEach((tallaData) {
      (tallaData as Map).keys.forEach((descripcionId) {
        descripcionIds.add(int.parse(descripcionId));
      });
    });

    // Obtener los nombres de las descripciones desde la base de datos
    final descripcionMaps = await db.query(
      'Descripcion',
      columns: ['id', 'descripcion'],
      where: 'id IN (${List.filled(descripcionIds.length, '?').join(', ')})',
      whereArgs: descripcionIds.toList(),
    );

    // Crear un mapa id -> nombre de descripción
    Map<int, String> descripcionMap = {
      for (var d in descripcionMaps) d['id'] as int: d['descripcion'] as String
    };

    // Construir la estructura correcta: talla -> { descripcion -> valor }
    Map<String, dynamic> datosCorregidos = {};
    datos.forEach((talla, descripciones) {
      datosCorregidos[talla] = (descripciones as Map).map(
          (descripcionId, valor) => MapEntry(
              descripcionMap[int.parse(descripcionId)] ?? 'Desconocido',
              valor));
    });

    return datosCorregidos;
  }

  Future<Set<String>> getDescripcionesUnicasByEstiloId(int idEstilo) async {
    final db = await DatabaseManager().database;

    // Obtener la fila con los datos de tolerancia
    final result = await db.query(
      'Tolerancia',
      columns: ['datos'],
      where: 'id_estilo = ?',
      whereArgs: [idEstilo],
    );

    if (result.isEmpty) return {};

    // Convertir la columna 'datos' de JSON a un Map
    final datosJson = result.first['datos'] as String?;
    if (datosJson == null) return {}; // Manejo de posible null

    Map<String, dynamic> datos = jsonDecode(datosJson);

    // Obtener los IDs de las descripciones únicas
    Set<int> descripcionIds = {};
    datos.values.forEach((tallaData) {
      (tallaData as Map).keys.forEach((descripcionId) {
        descripcionIds.add(int.parse(descripcionId));
      });
    });

    // Obtener los nombres de las descripciones desde la base de datos
    final descripcionMaps = await db.query(
      'Descripcion',
      columns: ['id', 'descripcion'],
      where: 'id IN (${List.filled(descripcionIds.length, '?').join(', ')})',
      whereArgs: descripcionIds.toList(),
    );

    // Crear un set con los nombres de las descripciones
    Set<String> descripcionesUnicas = {
      for (var d in descripcionMaps) d['descripcion'] as String
    };

    return descripcionesUnicas;
  }

  Future<int> updateTolerancia(Tolerancia tolerancia) async {
    final db = await DatabaseManager().database;
    return await db.update(
      'Tolerancia',
      tolerancia.toMap(),
      where: 'id = ?',
      whereArgs: [tolerancia.id],
    );
  }

  Future<int> deleteTolerancia(int id) async {
    final db = await DatabaseManager().database;
    return await db.delete(
      'Tolerancia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener tolerancias por estilo
  Future<Tolerancia?> getToleranciaByEstilo(int idEstilo) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Tolerancia',
      where: 'id_estilo = ?',
      whereArgs: [idEstilo],
    );

    if (maps.isNotEmpty) {
      return Tolerancia.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Tolerancia>> getToleranciasByEstilo(int idEstilo) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Tolerancia',
      where: 'id_estilo = ?',
      whereArgs: [idEstilo],
    );

    return List.generate(maps.length, (i) {
      return Tolerancia.fromMap(maps[i]);
    });
  }
}
