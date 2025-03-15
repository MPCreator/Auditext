import 'package:auditext/providers/inspeccion/inspeccion_provider.dart';

import '../../models/inspeccion/inspeccion.dart';

class AuditCalculatorService {
  final InspeccionProvider _inspeccionProvider;

  AuditCalculatorService({required InspeccionProvider inspeccionProvider})
      : _inspeccionProvider = inspeccionProvider;

  /// Retorna el tamaño de muestra para los parámetros indicados.
  Future<int?> getTamanoMuestra({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required int tamanoLote,
  }) async {
    final inspeccion = await _getMatchingInspeccion(
      nqaId: nqaId,
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
      tamanoLoteInput: tamanoLote,
    );

    return inspeccion?.tamanoMuestra;
  }

  /// Retorna el valor de 'aprobar' para los parámetros indicados.
  Future<int?> getAprobar({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required int tamanoLote,
  }) async {
    final inspeccion = await _getMatchingInspeccion(
      nqaId: nqaId,
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
      tamanoLoteInput: tamanoLote,
    );
    return inspeccion?.aprobar;
  }

  /// Retorna el valor de 'rechazar' para los parámetros indicados.
  Future<int?> getRechazar({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required int tamanoLote,
  }) async {
    final inspeccion = await _getMatchingInspeccion(
      nqaId: nqaId,
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
      tamanoLoteInput: tamanoLote,
    );
    return inspeccion?.rechazar;
  }

  /// Método privado que obtiene inspecciones optimizadas desde el provider y
  /// retorna aquella cuyo campo 'tamanoLote' (ejemplo "9-15") contenga al valor [tamanoLoteInput].
  Future<Inspeccion?> _getMatchingInspeccion({
    required int nqaId,
    required int tipoInspeccionId,
    required int nivelInspeccionId,
    required int tamanoLoteInput,
  }) async {
    // Se obtiene la lista de inspecciones filtrada por los parámetros básicos.
    final inspecciones = await _inspeccionProvider.fetchInspeccionesByCriteria(
      nqaId: nqaId, // Se asume que en la bd se guarda como String.
      tipoInspeccionId: tipoInspeccionId,
      nivelInspeccionId: nivelInspeccionId,
    );

    // Recorre la lista y filtra por el rango definido en 'tamanoLote'.
    for (var inspeccion in inspecciones) {
      // Se espera que el campo 'tamanoLote' tenga el formato "min-max".
      final partes = inspeccion.tamanoLote.split('-');
      if (partes.length == 2) {
        final min = int.tryParse(partes[0]);
        final max = int.tryParse(partes[1]);
        if (min != null && max != null) {
          if (tamanoLoteInput >= min && tamanoLoteInput <= max) {
            return inspeccion;
          }
        }
      }
    }
    // Si no se encontró ninguna coincidencia, retorna null o lanza una excepción según convenga.
    return null;
  }
}
