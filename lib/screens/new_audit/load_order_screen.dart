import 'dart:io';
import 'package:auditext/services/data_processing/data_cleaning_service.dart';
import 'package:auditext/services/data_processing/data_transforming_service.dart';
import 'package:auditext/services/data_processing/audit_calculator_service.dart';
import 'package:auditext/providers/user_settings_provider.dart';
import 'package:auditext/providers/inspeccion/inspeccion_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/auditoria/auditoria.dart';
import '../../models/auditoria/elemento.dart';
import '../../providers/auditoria/auditoria_provider.dart';
import '../../providers/auditoria/elemento_provider.dart';
import '../../providers/color_provider.dart';
import '../../providers/talla_provider.dart';
import '../../utils/routes/route_names.dart';

class LoadOrderScreen extends StatefulWidget {
  const LoadOrderScreen({super.key});

  @override
  State<LoadOrderScreen> createState() => _LoadOrderScreenState();
}

class _LoadOrderScreenState extends State<LoadOrderScreen> {
  List<List<dynamic>> _data = [];
  Set<int> _selectedColumns = {};
  String? _startRow;
  String? _endRow;
  List<Map<String, dynamic>> _result = [];
  bool _showNextButton = false;
  int? _createdAuditoriaId;

  // Etiquetas para las columnas en el orden de selección
  final List<String> columnLabels = ["CÓDIGO", "DESCRIPCIÓN", "TOTAL"];

  Future<void> _loadExcelFile() async {
    // Solicitar permisos en Android
    /*
    if (Platform.isAndroid) {
      PermissionStatus manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          openAppSettings();
          return;
        }
      }
    }

     */

    // Seleccionar el archivo Excel
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      try {
        final filePath = result.files.single.path;
        Excel excel;
        if (filePath == null) {
          if (result.files.single.bytes != null) {
            final bytes = result.files.single.bytes!;
            excel = Excel.decodeBytes(bytes);
          } else {
            return;
          }
        } else {
          final file = File(filePath);
          final bytes = file.readAsBytesSync();
          excel = Excel.decodeBytes(bytes);
        }
        _processExcelData(excel);
      } catch (e) {
        print("Error al procesar el archivo Excel: $e");
      }
    }
  }

  void _processExcelData(Excel excel) {
    try {
      final tableKey = excel.tables.keys.first;
      final rawData = excel.tables[tableKey]?.rows
          .map((row) => row.map((cell) => cell?.value).toList())
          .toList();

      if (rawData == null || rawData.isEmpty) {
        return;
      }

      final int numColumns = rawData[0].length;
      List<int> nonEmptyColumns = [];
      for (int col = 0; col < numColumns; col++) {
        bool hasData = rawData.any((row) =>
        row[col] != null && row[col].toString().trim().isNotEmpty);
        if (hasData) {
          nonEmptyColumns.add(col);
        }
      }

      final filteredData = rawData
          .map((row) => nonEmptyColumns.map((col) => row[col]).toList())
          .toList();

      setState(() {
        _data = filteredData;
        _selectedColumns.clear();
        _startRow = null;
        _endRow = null;
        _result.clear();
        _showNextButton = false;
      });
    } catch (e) {
      print("Error al procesar los datos del Excel: $e");
    }
  }

  Future<void> _generateResult() async {
    if (_selectedColumns.length == 3 && _startRow != null && _endRow != null) {
      final start = int.tryParse(_startRow!) ?? 0;
      final end = int.tryParse(_endRow!) ?? 0;

      if (start <= 0 ||
          end <= 0 ||
          start > end ||
          start > _data.length ||
          end > _data.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rango de filas no válido")),
        );
        return;
      }

      final selectedColumnIndexes = _selectedColumns.toList();
      final headerRow = _data[start - 1];

      final headers = selectedColumnIndexes.map((index) {
        final headerValue = headerRow[index]?.toString().trim();
        return (headerValue != null && headerValue.isNotEmpty)
            ? headerValue
            : "COLUMNA_${index + 1}";
      }).toList();

      final result = <Map<String, dynamic>>[];

      for (int i = start; i <= end - 1; i++) {
        final row = _data[i];
        final rowMap = <String, dynamic>{"#": i - start + 1};

        for (int j = 0; j < selectedColumnIndexes.length; j++) {
          rowMap[headers[j]] = row[selectedColumnIndexes[j]];
        }

        result.add(rowMap);
      }

      print("Datos entrada: $result");

      // Procesar datos con el servicio de limpieza
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      final tallaProvider = Provider.of<TallaProvider>(context, listen: false);

      await LimpiezaDatos.inicializar(colorProvider, tallaProvider);
      LimpiezaDatos.procesarDatos(result);

      setState(() {
        _result = LimpiezaDatos.datos;
      });

      print("Datos procesados: $_result");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos procesados correctamente")),
      );

      // Transformar datos agrupados
      TransformacionDatosService servicio = TransformacionDatosService();
      Map<String, Map<String, dynamic>> datosAgrupados =
      servicio.transformarDatos(_result);
      final elementoProvider =
      Provider.of<ElementoProvider>(context, listen: false);

      // Crear auditoría
      final auditoriaProvider =
      Provider.of<AuditoriaProvider>(context, listen: false);
      final nuevaAuditoria = Auditoria(
        proveedor: '',
        paisOrigen: '',
        paisDestino: '',
        marca: '',
        fechaEntrega: '',
        fechaAuditoria: '',
        auditora: '',
        po: '',
        subgrupo: '',
        resultado: '',
      );

      final auditoriaId = await auditoriaProvider.addAuditoria(nuevaAuditoria);

      setState(() {
        _createdAuditoriaId = auditoriaId;
        _showNextButton = true;
      });

      print("Auditoría creada");

      // Calcular totalAuditar
      final settingsProvider =
      Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.loadSettings();
      final settings = settingsProvider.settings.first;
      if (settings == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "No se encontraron los ajustes, verifique la configuración.")),
        );
        return;
      }
      final inspeccionProvider =
      Provider.of<InspeccionProvider>(context, listen: false);
      final auditCalculatorService =
      AuditCalculatorService(inspeccionProvider: inspeccionProvider);

      List<Elemento> elementos = [];
      for (final entry in datosAgrupados.entries) {
        final detalle = entry.value;
        final int totalGeneral = detalle['TOTAL'];
        int? totalAuditar = await auditCalculatorService.getTamanoMuestra(
          nqaId: settings.nqaId,
          tipoInspeccionId: settings.tipoInspeccionId,
          nivelInspeccionId: settings.nivelInspeccionId,
          tamanoLote: totalGeneral,
        );
        totalAuditar = totalAuditar ?? 0;

        final elemento = Elemento(
          auditoriaId: auditoriaId,
          codigo: entry.key,
          descripcion: detalle['DESCRIPCIÓN'],
          totalGeneral: totalGeneral,
          totalAuditar: totalAuditar,
          colores: Map<String, int>.from(detalle['COLORES']),
          tallas: Map<String, int>.from(detalle['TALLAS']),
          nota: '',
        );
        elementos.add(elemento);
      }
      print("Elementos obtenidos con totalAuditar calculado");
      for (final elemento in elementos) {
        await elementoProvider.addElemento(elemento);
        print('-------------------------');
        print('ID: ${elemento.id}');
        print('Auditoría ID: ${elemento.auditoriaId}');
        print('Código: ${elemento.codigo}');
        print('Descripción: ${elemento.descripcion}');
        print('Total General: ${elemento.totalGeneral}');
        print('Total a Auditar: ${elemento.totalAuditar}');
        print('Colores: ${elemento.colores}');
        print('Tallas: ${elemento.tallas}');
        print('-------------------------');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Selecciona 3 columnas y un rango válido de filas")),
      );
    }
  }

  void _navigateToPreAuditoria() {
    if (_createdAuditoriaId != null) {
      Navigator.of(context).pushNamed(
        RouteNames.preauditoria,
        arguments: _createdAuditoriaId,
      );
    }
  }

  void _toggleColumnSelection(int columnIndex) {
    setState(() {
      if (_selectedColumns.contains(columnIndex)) {
        _selectedColumns.remove(columnIndex);
      } else if (_selectedColumns.length < 3) {
        _selectedColumns.add(columnIndex);
      }
    });
  }

  Widget _buildColumnSelection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _data[0].length,
              (index) {
            String label = "Columna ${index + 1}";
            int selectionIndex = _selectedColumns.toList().indexOf(index);
            if (selectionIndex != -1) {
              label = columnLabels[selectionIndex];
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(label),
                selected: _selectedColumns.contains(index),
                onSelected: (_) => _toggleColumnSelection(index),
                selectedColor: Colors.blueAccent,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cargar Pedido"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _loadExcelFile,
                child: const Text("Cargar archivo Excel"),
              ),
              const SizedBox(height: 20),
              if (_data.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      _buildColumnSelection(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Fila inicial",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => _startRow = value,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Fila final",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => _endRow = value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: [const DataColumn(label: Text("#"))]
                                  .followedBy(
                                _data[0].asMap().entries.map(
                                      (entry) => DataColumn(
                                    label: Text(
                                      "Columna ${entry.key + 1}",
                                      style: TextStyle(
                                        fontWeight: _selectedColumns.contains(entry.key)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _selectedColumns.contains(entry.key)
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                              rows: _data.asMap().entries.map((entry) {
                                final rowIndex = entry.key + 1;
                                return DataRow(
                                  selected: rowIndex == int.tryParse(_startRow ?? '') ||
                                      rowIndex == int.tryParse(_endRow ?? ''),
                                  cells: [
                                    DataCell(Text(rowIndex.toString())),
                                  ]
                                      .followedBy(
                                    entry.value.map((cell) => DataCell(Text(cell.toString()))),
                                  )
                                      .toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateResult,
                child: const Text("Procesar datos"),
              ),
              if (_showNextButton)
                ElevatedButton(
                  onPressed: _navigateToPreAuditoria,
                  child: const Text("Siguiente"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
