import 'dart:convert';

import 'package:auditext/providers/talla_provider.dart';

import '../models/tolerancia.dart';

import 'package:flutter/material.dart';
import '../services/db/dao/tolerancia_dao.dart';
import 'descripcion_provider.dart';
import 'estilo_provider.dart';

class ToleranciaProvider with ChangeNotifier {
  final ToleranciaDao _toleranciaDao = ToleranciaDao();
  final List<Tolerancia> _tolerancias = [];

  List<Tolerancia> get tolerancias => List.unmodifiable(_tolerancias);

  // Cargar todas las tolerancias desde la base de datos si aún no están en memoria
  Future<void> fetchTolerancias() async {
    if (_tolerancias.isEmpty) {
      final toleranciasFromDb = await _toleranciaDao.getTolerancias();
      _tolerancias.addAll(toleranciasFromDb);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getToleranciaByEstiloId(int estiloId) async {
    final toleranciasFromDb =
        await _toleranciaDao.getToleranciaByEstiloId(estiloId);
    return toleranciasFromDb;
  }

  Future<List<String>> getDescripcionesUnicasListByEstiloId(
      int estiloId) async {
    final Set<String> descripcionesSet =
        await _toleranciaDao.getDescripcionesUnicasByEstiloId(estiloId);
    return descripcionesSet.toList();
  }

  // Agregar una nueva tolerancia y actualizar la memoria
  Future<void> addTolerancia(Tolerancia tolerancia) async {
    await _toleranciaDao.insertTolerancia(tolerancia);
    fetchTolerancias();
    notifyListeners();
  }

  // Actualizar una tolerancia existente y reflejar el cambio en memoria
  Future<void> updateTolerancia(Tolerancia tolerancia) async {
    if (tolerancia.id != null) {
      await _toleranciaDao.updateTolerancia(tolerancia);
      final index = _tolerancias.indexWhere((t) => t.id == tolerancia.id);
      if (index != -1) {
        _tolerancias[index] = tolerancia;
        notifyListeners();
      }
    } else {
      throw Exception(
          "El ID de la tolerancia no puede ser nulo para actualizar.");
    }
  }

  // Eliminar una tolerancia por su ID y actualizar la memoria
  Future<void> deleteTolerancia(int id) async {
    await _toleranciaDao.deleteTolerancia(id);
    _tolerancias.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Método para imprimir las tolerancias de un estilo específico
  Future<void> imprimirDatosEstilo(int idEstilo) async {
    final tolerancia = _tolerancias.firstWhere((t) => t.idEstilo == idEstilo,
        orElse: () => throw Exception('Estilo no encontrado'));

    print('Estilo ID: ${tolerancia.idEstilo}');
    tolerancia.datos.forEach((talla, descripciones) {
      print('Talla: $talla');
      descripciones.forEach((descripcion, valor) {
        print('$descripcion: $valor');
      });
    });
  }

  Future<void> imprimirDatosEstiloDetallado(
    int idEstilo, {
    required EstiloProvider estiloProvider,
    required TallaProvider tallaProvider,
    required DescripcionProvider descripcionProvider,
  }) async {
    // Verificar si la lista de estilos está vacía
    if (estiloProvider.estilos.isEmpty) {
      debugPrint(
          'La lista de estilos está vacía. Asegúrate de haber llamado a fetchEstilos.');
      throw Exception('No se han cargado los estilos.');
    }

    print("----");
    // Buscar el estilo por su ID y obtener el nombre
    final estilo = estiloProvider.estilos.firstWhere(
      (e) => e.id == idEstilo,
      orElse: () => throw Exception('Estilo no encontrado'),
    );

    print('Estilo: ${estilo.nombre}');

    // Verificar si la lista de tolerancias está vacía
    if (_tolerancias.isEmpty) {
      throw Exception('No se han cargado las tolerancias.');
    }

    // Obtener las tolerancias asociadas al estilo
    final tolerancia = _tolerancias.firstWhere(
      (t) => t.idEstilo == idEstilo,
      orElse: () => throw Exception('Tolerancia no encontrada para el estilo'),
    );

    tolerancia.datos.forEach((idTalla, descripciones) {
      final talla = tallaProvider.tallas.firstWhere(
        (t) => t.id.toString() == idTalla,
        orElse: () => throw Exception('Talla no encontrada'),
      );

      print('Talla: ${talla.rango}');

      descripciones.forEach((idDescripcion, valor) {
        final descripcion = descripcionProvider.descripciones.firstWhere(
          (d) => d.id.toString() == idDescripcion,
          orElse: () => throw Exception('Descripción no encontrada'),
        );

        print('${descripcion.descripcion}: $valor');
      });
      print("----");
    });
  }

  Future<Map<String, dynamic>> generarToleranciasJson({
    required int estiloId,
    required TallaProvider tallaProvider,
    // Mapa de tallas involucradas (por ejemplo, elemento.tallas)
    required Map<String, int> tallasInvolucradas,
    // Mapa que relaciona el nombre de la descripción (como se muestra en la UI) con su ID (en String)
    required Map<String, String> descripcionMapping,
  }) async {
    // Asegurarse de que las tallas estén cargadas
    await tallaProvider.fetchTallas();

    // Obtener las descripciones únicas (los nombres) para el estilo
    final List<String> descripciones =
        await getDescripcionesUnicasListByEstiloId(estiloId);

    // Obtener el registro de tolerancia para el estilo
    final Map<String, dynamic>? toleranciaRecord =
        await getToleranciaByEstiloId(estiloId);

    // Asignar toleranciaMap según la estructura del registro
    Map<String, dynamic> toleranciaMap = {};
    if (toleranciaRecord != null) {
      if (toleranciaRecord.containsKey("datos") &&
          toleranciaRecord["datos"] != null) {
        try {
          toleranciaMap = json.decode(toleranciaRecord["datos"]);
        } catch (e) {
          debugPrint('Error al parsear la tolerancia: $e');
        }
      } else {
        // Si no existe la llave "datos", se asume que el registro ya contiene el mapa deseado.
        toleranciaMap = Map<String, dynamic>.from(toleranciaRecord);
      }
    }

    // Construir el mapeo de tallas: de rango (ej: "2-4") -> id de la talla (como String)
    final Map<String, String> tallasMapping = {
      for (var t in tallaProvider.tallas) t.rango: t.id.toString(),
    };

    // Construir la estructura final usando solo las tallas involucradas del elemento
    Map<String, dynamic> toleranciasPorDescripcion = {};
    for (var descripcion in descripciones) {
      Map<String, dynamic> toleranciasPorTalla = {};

      for (var tallaKey in tallasInvolucradas.keys) {
        final String? tallaId = tallasMapping[tallaKey];
        final dynamic valor =
            (tallaId != null && toleranciaMap[tallaId] != null)
                ? toleranciaMap[tallaId][descripcion]
                : null;

        toleranciasPorTalla[tallaKey] = valor;
      }
      toleranciasPorDescripcion[descripcion] = toleranciasPorTalla;
    }

    return {"Tolerancias": toleranciasPorDescripcion};
  }
}
