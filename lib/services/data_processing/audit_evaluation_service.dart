import 'package:flutter/cupertino.dart';

import '../../models/auditoria/analisis_dimensional.dart';
import '../../models/auditoria/auditoria.dart';
import '../../models/auditoria/defecto_visual.dart';
import '../../models/auditoria/elemento.dart';
import '../../models/user_settings.dart';
import '../../providers/descripcion_provider.dart';
import '../../providers/estilo_provider.dart';
import '../../providers/inspeccion/inspeccion_provider.dart';
import '../../providers/inspeccion/margen_error_provider.dart';
import '../../providers/inspeccion/nivel_inspeccion_provider.dart';
import '../../providers/inspeccion/nqa_provider.dart';
import '../../providers/inspeccion/tipo_inspeccion_provider.dart';
import '../../providers/talla_provider.dart';
import '../../providers/tolerancia_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../db/dao/auditoria/analisis_dimensional_dao.dart';
import '../db/dao/auditoria/defecto_visual_dao.dart';
import '../db/dao/auditoria/elemento_dao.dart';

class AuditDefectEvaluationService {
  // Función auxiliar para sumar los defectos visuales de 'mayor' y 'menor'
  Map<String, int> _sumDefectosVisuales(List<DefectoVisual> defectos) {
    int sumaMayor = 0;
    int sumaMenor = 0;
    for (final defecto in defectos) {
      sumaMayor += defecto.mayor;
      sumaMenor += defecto.menor;
    }
    return {'sumaMayor': sumaMayor, 'sumaMenor': sumaMenor};
  }

  // Función auxiliar para calcular el total de defectos: (mayor + menor) / tolerancia
  double _computeTotalDefectos(int sumaMayor, int sumaMenor, double tolerancia) {
    final total = (sumaMayor + sumaMenor / tolerancia);
    return total;
  }

  /// Evalúa los defectos visuales para un elemento específico.
  /// Si ocurre un error, se imprime información de debugging.
  Future<String> evaluarDefectosVisuales(int elementId) async {
    try {
      // 1. Obtener el elemento
      final elementoDAO = ElementoDAO();
      Elemento elemento = await elementoDAO.getElementoById(elementId);

      // 2. Obtener defectos visuales para el elemento.
      final defectoVisualDAO = DefectoVisualDAO();
      List<DefectoVisual> defectos =
      await defectoVisualDAO.getDefectoVisualByElementoId(elementId);
      if (defectos.isEmpty) {
        return "APROBADO";
      }

      // 3. Sumar defectos
      final sums = _sumDefectosVisuales(defectos);
      int sumaMayor = sums['sumaMayor']!;
      int sumaMenor = sums['sumaMenor']!;

      // 4. Obtener settings mediante la misma lógica
      final settingsProvider = SettingsProvider();
      await settingsProvider.loadSettings();
      List<UserSettings> settingsList = settingsProvider.settings;
      if (settingsList.isEmpty) {
        throw Exception("No se encontraron settings para evaluar");
      }

      // Inicializar los providers necesarios.
      final tipoInspeccionProvider = TipoInspeccionProvider();
      await tipoInspeccionProvider.fetchTipoInspecciones();
      final nivelInspeccionProvider = NivelInspeccionProvider();
      await nivelInspeccionProvider.fetchNivelInspecciones();
      final nqaProvider = NqaProvider();
      await nqaProvider.fetchNqas();
      final margenErrorProvider = MargenErrorProvider();
      await margenErrorProvider.fetchMargenErrores();
      final inspeccionProvider = InspeccionProvider();
      await inspeccionProvider.fetchInspecciones();

      // Construir el settingsJson similar a tu otro servicio
      List<Map<String, dynamic>> settingsJson = await Future.wait(
        settingsList.map((setting) async {
          final tipo = tipoInspeccionProvider.tipoInspecciones.firstWhere(
                (t) => t.id == setting.tipoInspeccionId,
          );
          final nivel = nivelInspeccionProvider.nivelInspecciones.firstWhere(
                (n) => n.id == setting.nivelInspeccionId,
          );
          final nqa = nqaProvider.nqas.firstWhere(
                (n) => n.id == setting.nqaId,
          );
          final margen = margenErrorProvider.margenes.firstWhere(
                (m) => m.id == setting.margenErrorId,
          );
          final inspeccion = await inspeccionProvider.fetchInspeccionForTotalGeneral(
            nqaId: setting.nqaId,
            tipoInspeccionId: setting.tipoInspeccionId,
            nivelInspeccionId: setting.nivelInspeccionId,
            totalGeneral: elemento.totalGeneral,
          );
          return {
            'seccion': setting.seccion,
            'tipoInspeccion': tipo.nombre,
            'nivelInspeccion': nivel.nombre,
            'nqa': nqa.nombre,
            'margenError': margen.margen, // Valor de tolerancia.
            'aprobar': inspeccion?.aprobar ?? 0,
            'rechazar': inspeccion?.rechazar ?? 0,
          };
        }).toList(),
      );

      // Para evaluar usamos el primer setting (ajustá según necesites)
      final setting = settingsJson.first;
      double tolerancia = (setting['margenError'] as num).toDouble();
      double thresholdAprovar = (setting['aprobar'] as num).toDouble();

      // 5. Calcular el total de defectos visuales.
      double totalDefectos = _computeTotalDefectos(sumaMayor, sumaMenor, tolerancia);

      // 6. Comparar y devolver el resultado.
      String resultado = totalDefectos <= thresholdAprovar ? "APROBADO" : "REPROBADO";
      return resultado;
    } catch (e, stacktrace) {
      debugPrint("DEBUG: Error en evaluarDefectosVisuales: $e");
      debugPrint(stacktrace.toString());
      throw e;
    }
  }

  /// Obtiene los valores de 'aprobar' y 'rechazar' para un elemento.
  Future<Map<String, int>> obtenerAprobarRechazar(int elementId) async {
    try {
      // Obtener el elemento
      final elementoDAO = ElementoDAO();
      Elemento elemento = await elementoDAO.getElementoById(elementId);

      // Cargar settings
      final settingsProvider = SettingsProvider();
      await settingsProvider.loadSettings();
      List<UserSettings> settingsList = settingsProvider.settings;
      if (settingsList.isEmpty) {
        throw Exception("No se encontraron settings para evaluar");
      }

      // Inicializar los providers necesarios
      final tipoInspeccionProvider = TipoInspeccionProvider();
      await tipoInspeccionProvider.fetchTipoInspecciones();
      final nivelInspeccionProvider = NivelInspeccionProvider();
      await nivelInspeccionProvider.fetchNivelInspecciones();
      final nqaProvider = NqaProvider();
      await nqaProvider.fetchNqas();
      final margenErrorProvider = MargenErrorProvider();
      await margenErrorProvider.fetchMargenErrores();
      final inspeccionProvider = InspeccionProvider();
      await inspeccionProvider.fetchInspecciones();

      // Construir el settingsJson similar a lo que ya usás
      List<Map<String, dynamic>> settingsJson = await Future.wait(
        settingsList.map((setting) async {
          final tipo = tipoInspeccionProvider.tipoInspecciones.firstWhere(
                (t) => t.id == setting.tipoInspeccionId,
          );
          final nivel = nivelInspeccionProvider.nivelInspecciones.firstWhere(
                (n) => n.id == setting.nivelInspeccionId,
          );
          final nqa = nqaProvider.nqas.firstWhere(
                (n) => n.id == setting.nqaId,
          );
          final margen = margenErrorProvider.margenes.firstWhere(
                (m) => m.id == setting.margenErrorId,
          );
          final inspeccion = await inspeccionProvider.fetchInspeccionForTotalGeneral(
            nqaId: setting.nqaId,
            tipoInspeccionId: setting.tipoInspeccionId,
            nivelInspeccionId: setting.nivelInspeccionId,
            totalGeneral: elemento.totalGeneral,
          );
          return {
            'seccion': setting.seccion,
            'tipoInspeccion': tipo.nombre,
            'nivelInspeccion': nivel.nombre,
            'nqa': nqa.nombre,
            'margenError': margen.margen, // tolerancia
            'aprobar': inspeccion?.aprobar ?? 0,
            'rechazar': inspeccion?.rechazar ?? 0,
          };
        }).toList(),
      );

      // Usamos el primer setting para obtener los valores.
      final setting = settingsJson.first;
      return {
        'aprobar': (setting['aprobar'] as num).toInt(),
        'rechazar': (setting['rechazar'] as num).toInt(),
      };
    } catch (e, stacktrace) {
      debugPrint("DEBUG: Error en obtenerAprobarRechazar: $e");
      debugPrint(stacktrace.toString());
      throw e;
    }
  }

  /// Evalúa el análisis dimensional para un elemento usando la lógica de la API
  /// y retorna "APROVADO" o "REPROVADO".
  Future<String> evaluarAnalisisDimensional(int elementId) async {
    try {
      // 1. Obtener el elemento.
      final elementoDAO = ElementoDAO();
      Elemento elemento = await elementoDAO.getElementoById(elementId);

      // 2. Obtener registros de análisis dimensional.
      final analisisDimensionalDAO = AnalisisDimensionalDAO();
      List<AnalisisDimensional> analisisList =
      await analisisDimensionalDAO.getAnalisisDimensionalByElementoId(elementId);
      // Si no hay registros, se retorna "APROVADO" por defecto.
      if (analisisList.isEmpty) {
        debugPrint("DEBUG: No se encontraron análisis dimensional para el elemento $elementId. Retornando APROBADO.");
        return "APROBADO";
      }
      List<Map<String, dynamic>> analisisData = analisisList.map((analisis) {
        return {
          'talla': analisis.talla,
          'toleranciaDescripcion': analisis.toleranciaDescripcion,
          'color': analisis.color,
          'valor': analisis.valor,
        };
      }).toList();
      debugPrint("DEBUG: Analisis dimensional count: ${analisisData.length}");

      // 3. Cargar settings (se espera tener al menos 2 settings para esta evaluación).
      final settingsProvider = SettingsProvider();
      await settingsProvider.loadSettings();
      List<UserSettings> settingsList = settingsProvider.settings;
      if (settingsList.length < 2) {
        throw Exception("No hay suficientes settings para evaluar análisis dimensional");
      }

      // Inicializar providers para construir el settingsJson.
      final tipoInspeccionProvider = TipoInspeccionProvider();
      await tipoInspeccionProvider.fetchTipoInspecciones();
      final nivelInspeccionProvider = NivelInspeccionProvider();
      await nivelInspeccionProvider.fetchNivelInspecciones();
      final nqaProvider = NqaProvider();
      await nqaProvider.fetchNqas();
      final margenErrorProvider = MargenErrorProvider();
      await margenErrorProvider.fetchMargenErrores();
      final inspeccionProvider = InspeccionProvider();
      await inspeccionProvider.fetchInspecciones();

      List<Map<String, dynamic>> settingsJson = await Future.wait(
        settingsList.map((setting) async {
          final tipo = tipoInspeccionProvider.tipoInspecciones.firstWhere(
                (t) => t.id == setting.tipoInspeccionId,
          );
          final nivel = nivelInspeccionProvider.nivelInspecciones.firstWhere(
                (n) => n.id == setting.nivelInspeccionId,
          );
          final nqa = nqaProvider.nqas.firstWhere(
                (n) => n.id == setting.nqaId,
          );
          final margen = margenErrorProvider.margenes.firstWhere(
                (m) => m.id == setting.margenErrorId,
          );
          final inspeccion = await inspeccionProvider.fetchInspeccionForTotalGeneral(
            nqaId: setting.nqaId,
            tipoInspeccionId: setting.tipoInspeccionId,
            nivelInspeccionId: setting.nivelInspeccionId,
            totalGeneral: elemento.totalGeneral,
          );
          return {
            'seccion': setting.seccion,
            'tipoInspeccion': tipo.nombre,
            'nivelInspeccion': nivel.nombre,
            'nqa': nqa.nombre,
            'margenError': margen.margen,
            'aprobar': inspeccion?.aprobar ?? 0,
            'rechazar': inspeccion?.rechazar ?? 0,
          };
        }).toList(),
      );
      debugPrint("DEBUG: Settings JSON construido, count: ${settingsJson.length}");

      // 4. Generar tolerancias JSON usando ToleranciaProvider.
      final estiloProvider = EstiloProvider();
      // Asegurarse de obtener el estilo asociado al elemento.
      final int? estiloId = await estiloProvider.getEstiloIdByNombre(elemento.codigo);
      if (estiloId == null) {
        throw Exception("No se encontró estilo para el elemento ${elemento.codigo}");
      }
      final tallaProvider = TallaProvider();
      final descripcionProvider = DescripcionProvider();
      final toleranciasJson = await ToleranciaProvider().generarToleranciasJson(
        estiloId: estiloId,
        tallaProvider: tallaProvider,
        tallasInvolucradas: elemento.tallas,
        descripcionMapping: await descripcionProvider.getDescripcionMapping(),
      );
      debugPrint("DEBUG: Tolerancias JSON obtenido.");

      // 5. Extraer datos: tolerancias y margenError del segundo setting (índice 1).
      final Map<String, dynamic> toleranciasData =
      toleranciasJson["Tolerancias"] as Map<String, dynamic>;
      double marginError = (settingsJson[1]['margenError'] as num).toDouble();
      double thresholdAprobar = (settingsJson[1]['aprobar'] as num).toDouble();
      debugPrint("DEBUG: marginError: $marginError, thresholdAprovar: $thresholdAprobar");

      // 6. Inicializar sumas globales para defectos externos e internos.
      int globalExternalSum = 0;
      int globalInternalSum = 0;

      // 7. Recorrer cada talla del elemento.
      // Se asume que elemento.tallas es un Map<String, int>.
      elemento.tallas.forEach((talla, cantidad) {
        // Obtener hasta 8 tolerancias (según los keys disponibles).
        List<String> tolKeys = toleranciasData.keys.toList();
        int maxTol = tolKeys.length < 8 ? tolKeys.length : 8;
        for (int idx = 0; idx < maxTol; idx++) {
          String toleranceDesc = tolKeys[idx];
          // Obtener el valor base para esta talla.
          var baseValDynamic = toleranciasData[toleranceDesc]?[talla];
          if (baseValDynamic == null) {
            continue;
          }
          double baseVal = (baseValDynamic as num).toDouble();
          double x = baseVal * marginError / 100.0;
          debugPrint("DEBUG: Talla: $talla, tolerancia: $toleranceDesc, baseVal: $baseVal, x: $x");

          // Filtrar registros de análisis que correspondan a esta talla y tolerancia.
          List<Map<String, dynamic>> records = analisisData.where((rec) {
            return (rec['talla'] == talla) &&
                ((rec['toleranciaDescripcion'] as String).trim().toUpperCase() ==
                    toleranceDesc.trim().toUpperCase());
          }).toList();
          debugPrint("DEBUG: Talla: $talla, tolerancia: $toleranceDesc, registros count: ${records.length}");

          // Inicializar conteos para cada color.
          List<String> colors;
          colors = (elemento.colores as Map).keys.cast<String>().toList();
                  Map<String, List<int>> counts = {};
          for (var color in colors) {
            counts[color] = [0, 0, 0, 0, 0]; // 5 categorías.
          }

          // Clasificar cada registro en una categoría.
          for (var rec in records) {
            double recValor = (rec['valor'] as num).toDouble();
            double d = recValor - baseVal;
            int category;
            if (d > x) {
              category = 0; // > x
            } else if (d > 0) {
              category = 1; // (0, x]
            } else if (d == 0) {
              category = 2; // 0
            } else if (d >= -x) {
              category = 3; // [-x, 0)
            } else {
              category = 4; // < -x
            }
            String recColor = rec['color'] as String;
            if (counts.containsKey(recColor)) {
              counts[recColor]![category] += 1;
            }
          }

          // Sumar conteos: externos = categorías 0 y 4; internos = categorías 1 y 3.
          counts.forEach((color, countList) {
            int external = countList[0] + countList[4];
            int internal = countList[1] + countList[3];
            globalExternalSum += external;
            globalInternalSum += internal;
          });
        }
      });
      debugPrint("DEBUG: Suma externa global: $globalExternalSum, interna global: $globalInternalSum");

      // 8. Calcular el total de defectos.
      double totalDefects = (globalExternalSum + globalInternalSum/marginError) ;
      debugPrint("DEBUG: Total defectos: $totalDefects");

      // 9. Comparar con el umbral del segundo setting para determinar el resultado.
      String result = totalDefects <= thresholdAprobar ? "APROBADO" : "REPROBADO";
      debugPrint("DEBUG: Resultado evaluación análisis dimensional: $result");
      return result;
    } catch (e, stacktrace) {
      debugPrint("DEBUG: Error en evaluarAnalisisDimensional: $e");
      debugPrint(stacktrace.toString());
      throw e;
    }
  }

  Future<String> evaluarAmbosCriterios(int elementoId) async {

    final resultadoVisuales = await evaluarDefectosVisuales(elementoId);
    final resultadoOtro = await evaluarAnalisisDimensional(elementoId);

    return (resultadoVisuales == "APROBADO" && resultadoOtro == "APROBADO")
        ? "APROBADO"
        : "REPROBADO";
  }

}
