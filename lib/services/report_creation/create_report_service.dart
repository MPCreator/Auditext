import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:auditext/models/auditoria/analisis_dimensional.dart';
import 'package:auditext/models/auditoria/imagen_empaque.dart';
import 'package:auditext/models/auditoria/imagen_visual.dart';
import 'package:auditext/models/user_settings.dart';
import 'package:auditext/providers/inspeccion/inspeccion_provider.dart';
import 'package:auditext/providers/inspeccion/margen_error_provider.dart';
import 'package:auditext/providers/inspeccion/nivel_inspeccion_provider.dart';
import 'package:auditext/providers/inspeccion/nqa_provider.dart';
import 'package:auditext/providers/inspeccion/tipo_inspeccion_provider.dart';
import 'package:auditext/providers/user_settings_provider.dart';
import 'package:auditext/services/db/dao/auditoria/analisis_dimensional_dao.dart';
import 'package:auditext/services/db/dao/auditoria/imagen_empaque_dao.dart';
import 'package:auditext/services/db/dao/auditoria/imagen_medida_dao.dart';
import 'package:auditext/services/db/dao/auditoria/imagen_visual_dao.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/auditoria/auditoria.dart';
import '../../models/auditoria/defecto_visual.dart';
import '../../models/auditoria/elemento.dart';
import '../../models/auditoria/imagen_medida.dart';
import '../db/dao/auditoria/defecto_visual_dao.dart';
import '../db/dao/auditoria/elemento_dao.dart';
import 'package:auditext/providers/tolerancia_provider.dart';
import 'package:auditext/providers/estilo_provider.dart';
import 'package:auditext/providers/talla_provider.dart';
import 'package:auditext/providers/descripcion_provider.dart';

class CreateAuditReportService {
  // URL del endpoint para generar el Excel.
  //static const String _endpoint = 'http://10.0.2.2:5000/generar-excel';
 // static const String _endpoint = 'http://192.168.18.23:5000/generar-excel';
  // URL del endpoint para enviar el ZIP y obtener el enlace de descarga.
  //static const String _zipEndpoint = 'http://10.0.2.2:5000/generar-enlace-zip';
  //static const String _zipEndpoint = 'http://192.168.18.23:5000/generar-enlace-zip';

// Nueva URL con ngrok
  static const String _endpoint = 'https://daring-nominally-swift.ngrok-free.app/generar-excel';
  static const String _zipEndpoint = 'https://daring-nominally-swift.ngrok-free.app/generar-enlace-zip';

  Future<String> encodeImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  /// Crea los reportes, genera el ZIP y retorna la URL de descarga del ZIP.
  Future<String> createAndExportAuditReports(Auditoria auditoria) async {
    final ElementoDAO _elementoDAO = ElementoDAO();
    final _imagenEmpaqueDAO = ImagenEmpaqueDAO();
    final _imagenVisualDAO = ImagenVisualDAO();
    final _imagenMedidaDAO = ImagenMedidaDAO();
    final _defectoVisualDAO = DefectoVisualDAO();
    final _analisisDimensionalDAO = AnalisisDimensionalDAO();
    final InspeccionProvider inspeccionProvider = InspeccionProvider();
    await inspeccionProvider.fetchInspecciones();

    final List<Elemento> elementos =
        await _elementoDAO.getElementosByAuditoriaId(auditoria.id!);

    if (elementos.isEmpty) {
      throw Exception(
          "No se encontraron elementos para la auditoría ${auditoria.id}");
    }

    // Directorio temporal para almacenar los reportes individuales.
    final tempDir = await getTemporaryDirectory();
    final reportsDir = Directory('${tempDir.path}/reports_${auditoria.po}');
    if (!(await reportsDir.exists())) {
      await reportsDir.create(recursive: true);
    }

    // Para cada elemento se crea un reporte Excel individual.
    for (final Elemento elemento in elementos) {
      final List<ImagenEmpaque> imagenesEmpaque = await _imagenEmpaqueDAO
          .getImagenEmpaqueByElementoId(elemento.id as int);
      final List<ImagenVisual> imagenesVisual = await _imagenVisualDAO
          .getImagenVisualByElementoId(elemento.id as int);
      final List<ImagenMedida> imagenesMedida = await _imagenMedidaDAO
          .getImagenMedidaByElementoId(elemento.id as int);
      final List<DefectoVisual> defectosVisual = await _defectoVisualDAO
          .getDefectoVisualByElementoId(elemento.id as int);
      final List<AnalisisDimensional> analisisDimensional =
          await _analisisDimensionalDAO
              .getAnalisisDimensionalByElementoId(elemento.id as int);

      final List<Map<String, String>> imagenesEmpaqueData = await Future.wait(
          imagenesEmpaque.map((img) async => {
            'imagen': await encodeImageToBase64(img.imagen),
            'titulo': img.titulo,
          }).toList());
      final List<Map<String, String>> imagenesVisualData = await Future.wait(
          imagenesVisual.map((img) async => {
            'imagen': await encodeImageToBase64(img.imagen),
            'titulo': img.titulo,
          }).toList());

      final List<Map<String, String>> imagenesMedidaData = await Future.wait(
          imagenesMedida.map((img) async => {
            'imagen': await encodeImageToBase64(img.imagen),
            'titulo': img.titulo,
          }).toList());


      // Integración de los JSONs de defectos, análisis dimensional, tolerancias y settings.
      List<Map<String, dynamic>> defectosVisualData =
          defectosVisual.map((defecto) {
        return {
          'codigo': defecto.codigo,
          'descripcion': defecto.descripcion,
          'color': defecto.color,
          'talla': defecto.talla,
          'origenZona': defecto.origenZona,
          'mayor': defecto.mayor,
          'menor': defecto.menor,
        };
      }).toList();

      List<Map<String, dynamic>> analisisDimensionalData =
          analisisDimensional.map((analisis) {
        return {
          'talla': analisis.talla,
          'toleranciaDescripcion': analisis.toleranciaDescripcion,
          'color': analisis.color,
          'valor': analisis.valor,
        };
      }).toList();

      final ToleranciaProvider toleranciaProvider = ToleranciaProvider();
      final EstiloProvider estiloProvider = EstiloProvider();
      final TallaProvider tallaProvider = TallaProvider();
      final DescripcionProvider descripcionProvider = DescripcionProvider();

      final int? estiloId =
          await estiloProvider.getEstiloIdByNombre(elemento.codigo);
      if (estiloId == null) {
        print("No se encontró el estilo para el código: ${elemento.codigo}");
        continue;
      }

      final Map<String, String> descripcionMapping =
          await descripcionProvider.getDescripcionMapping();

      final Map<String, dynamic> toleranciasJson =
          await toleranciaProvider.generarToleranciasJson(
        estiloId: estiloId,
        tallaProvider: tallaProvider,
        tallasInvolucradas: elemento.tallas,
        descripcionMapping: descripcionMapping,
      );

      final SettingsProvider settingsProvider = SettingsProvider();
      await settingsProvider.loadSettings();
      final List<UserSettings> settingsList = settingsProvider.settings;

      final NqaProvider nqaProvider = NqaProvider();
      await nqaProvider.fetchNqas();

      final TipoInspeccionProvider tipoInspeccionProvider =
          TipoInspeccionProvider();
      await tipoInspeccionProvider.fetchTipoInspecciones();

      final NivelInspeccionProvider nivelInspeccionProvider =
          NivelInspeccionProvider();
      await nivelInspeccionProvider.fetchNivelInspecciones();

      final MargenErrorProvider margenErrorProvider = MargenErrorProvider();
      await margenErrorProvider.fetchMargenErrores();

      final List<Map<String, dynamic>> settingsJson =
          await Future.wait(settingsList.map((setting) async {
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

        final inspeccion =
            await inspeccionProvider.fetchInspeccionForTotalGeneral(
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
      }).toList());

      Map<String, dynamic> data = {
        'auditoria': {
          'proveedor': auditoria.proveedor,
          'paisOrigen': auditoria.paisOrigen,
          'paisDestino': auditoria.paisDestino,
          'marca': auditoria.marca,
          'fechaEntrega': auditoria.fechaEntrega,
          'fechaAuditoria': auditoria.fechaAuditoria,
          'auditora': auditoria.auditora,
          'po': auditoria.po,
          'subgrupo': auditoria.subgrupo,
        },
        'elemento': {
          'codigo': elemento.codigo,
          'descripcion': elemento.descripcion,
          'totalGeneral': elemento.totalGeneral,
          'totalAuditar': elemento.totalAuditar,
          'tallas': elemento.tallas,
          'colores': elemento.colores,
          'nota': elemento.nota,
        },
        'imagenesEmpaque': imagenesEmpaqueData,
        'imagenesVisual': imagenesVisualData,
        'imagenesMedida': imagenesMedidaData,
        'defectosVisual': defectosVisualData,
        'analisisDimensional': analisisDimensionalData,
        'tolerancias': toleranciasJson,
        'settings': settingsJson,
      };

      // Llamada POST a la API para generar el Excel.
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        Uint8List fileBytes = response.bodyBytes;
        final file = File('${reportsDir.path}/${elemento.codigo}.xlsx');
        await file.writeAsBytes(fileBytes);
        print('Reporte guardado: ${file.path}');
      } else {
        throw Exception('Error al generar el Excel: ${response.statusCode}');
      }
    }

    // Comprimir los reportes en un ZIP.
    final zipFilePath = await _createZipFromDirectory(reportsDir);
    final zipFile = File(zipFilePath);
    final zipBytes = await zipFile.readAsBytes();

    // Enviar el ZIP a la API y obtener la URL de descarga.
    final uri = Uri.parse(_zipEndpoint);
    final request = http.MultipartRequest('POST', uri)
      ..fields['audit_name'] = auditoria.po
      ..files.add(http.MultipartFile.fromBytes(
        'zip_file',
        zipBytes,
        filename: '${auditoria.po}.zip',
      ));

    final streamedResponse = await request.send();
    final responseZip = await http.Response.fromStream(streamedResponse);
    if (responseZip.statusCode == 200) {
      final jsonResponse = jsonDecode(responseZip.body);
      final downloadUrl = jsonResponse['download_url'];
      print('Enlace de descarga generado: $downloadUrl');

      // Limpiar archivos temporales.
      await reportsDir.delete(recursive: true);
      await zipFile.delete();

      // Retornar la URL al caller.
      return downloadUrl;
    } else {
      throw Exception(
          'Error al generar enlace del ZIP: ${responseZip.statusCode}');
    }
  }

  Future<String> _createZipFromDirectory(Directory sourceDir) async {
    final zipFilePath = '${sourceDir.path}.zip';
    final encoder = ZipFileEncoder();
    encoder.create(zipFilePath);
    encoder.addDirectory(sourceDir);
    encoder.close();

    print('ZIP creado: $zipFilePath');
    return zipFilePath;
  }
}
