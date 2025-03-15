import '../../providers/color_provider.dart';
import '../../providers/talla_provider.dart';

class LimpiezaDatos {
  static List<Map<String, dynamic>> datos = [];
  static List<String> tallasOficiales = [];
  static Map<String, String> coloresOficiales = {};
  static final Map<String, String> coloresNormalizados = {
    'COGNAC': 'COGÑAC',
    'CONAC': 'COGÑAC',
    'ALMOND': 'ALMENDRA',
    'CARBON': 'CARBÓN',
    'ROSADO BEBE': 'ROSADO BEBÉ',
    // Otras normalizaciones...
  };

  static Future<void> inicializar(
      ColorProvider colorProvider, TallaProvider tallaProvider) async {
    // Cargar colores
    await colorProvider.fetchColors();
    coloresOficiales = {
      for (var color in colorProvider.colors)
        color.nombre.toUpperCase(): color.nombre.toUpperCase()
    };

    // Cargar tallas
    await tallaProvider.fetchTallas();
    tallasOficiales =
        tallaProvider.tallas.map((t) => t.rango.toUpperCase()).toList();
  }

  static void procesarDatos(List<Map<String, dynamic>> entrada) {
    datos = entrada.map((fila) {
      String? codigo = fila.entries.elementAt(1).value?.toString();
      String? descripcion = fila.entries.elementAt(2).value?.toString();
      String? total = fila.entries.elementAt(3).value?.toString();

      if (descripcion != null) {
        descripcion = descripcion
            .replaceAll(RegExp(r'TEXTILON', caseSensitive: false), '')
            .trim();

        // Aplicar normalización de colores
        descripcion = _normalizarColor(descripcion);

        String talla = _extraerTalla(descripcion);
        String color = _extraerColor(descripcion);

        descripcion = descripcion
            .replaceAll(
                RegExp(r'\b' + RegExp.escape(talla) + r'\b',
                    caseSensitive: false),
                '')
            .replaceAll(
                RegExp(r'(^|\s)' + RegExp.escape(color) + r'($|\s)',
                    caseSensitive: false),
                ' ')
            .trim();

        return {
          "CÓDIGO": codigo ?? "",
          "DESCRIPCIÓN": descripcion,
          "TOTAL": total ?? "",
          "TALLA": talla,
          "COLOR": color
        };
      }

      return {
        "CÓDIGO": codigo ?? "",
        "DESCRIPCIÓN": "",
        "TOTAL": total ?? "",
        "TALLA": "",
        "COLOR": ""
      };
    }).toList();
  }

  static String _normalizarColor(String descripcion) {
    coloresNormalizados.forEach((noNormalizado, normalizado) {
      descripcion = descripcion.replaceAll(
        RegExp(r'\b' + RegExp.escape(noNormalizado) + r'\b',
            caseSensitive: false),
        normalizado,
      );
    });
    return descripcion;
  }

  static String _extraerTalla(String descripcion) {
    for (String talla in tallasOficiales) {
      if (RegExp(r'\b' + RegExp.escape(talla) + r'\b', caseSensitive: false)
          .hasMatch(descripcion)) {
        return talla;
      }
    }
    return "";
  }

  static String _extraerColor(String descripcion) {
    for (String color in coloresOficiales.keys) {
      final pattern = RegExp(r'(^|\s)' + RegExp.escape(color) + r'($|\s)',
          caseSensitive: false);
      if (pattern.hasMatch(descripcion)) {
        return coloresOficiales[color]!;
      }
    }
    return "";
  }
}
