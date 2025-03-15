import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Column Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExcelColumnSelector(),
    );
  }
}

class ExcelColumnSelector extends StatefulWidget {
  const ExcelColumnSelector({super.key});

  @override
  State<ExcelColumnSelector> createState() => _ExcelColumnSelectorState();
}

class _ExcelColumnSelectorState extends State<ExcelColumnSelector> {
  String? filePath;
  List<List<Data?>> excelData = [];
  int? codigoColumn;
  int? descripcionColumn;
  int? totalColumn;
  int? headerRow;

  Future<void> seleccionarArchivo() async {
    String? path = await seleccionarArchivoExcel();
    if (path != null) {
      setState(() {
        filePath = path;
      });
      await leerDatos();
    }
  }

  Future<String?> seleccionarArchivoExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }

  Future<void> leerDatos() async {
    if (filePath != null) {
      excelData = await leerExcel(filePath!);
      setState(() {}); // Actualizar la interfaz con los datos leídos
    }
  }

  Future<List<List<Data?>>> leerExcel(String filePath) async {
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<List<Data?>> datosLeidos = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var row in sheet.rows) {
        datosLeidos.add(row);
      }
    }
    return datosLeidos;
  }

  Future<void> crearNuevoExcel() async {
    if (headerRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una fila de encabezado primero.')),
      );
      return;
    }

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Escribir encabezados personalizados
    sheet.appendRow([TextCellValue('Código'), TextCellValue('Descripción'), TextCellValue('Total')]);

    // Escribir los datos a partir de la fila de encabezado seleccionada
    for (var rowIndex = headerRow! + 1; rowIndex < excelData.length; rowIndex++) {
      var row = excelData[rowIndex];
      var codigo = row[codigoColumn!]?.value ?? '';
      var descripcion = row[descripcionColumn!]?.value ?? '';
      var total = row[totalColumn!]?.value ?? '';
      sheet.appendRow([TextCellValue(codigo as String),TextCellValue (descripcion as String), TextCellValue(total as String)]);
    }

    // Guardar el archivo en la ruta de documentos
    Directory directory = await getApplicationDocumentsDirectory();
    String outputPath = '${directory.path}/nuevo_archivo.xlsx';
    var bytes = excel.encode();
    File(outputPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archivo guardado en: $outputPath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Column Selector'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: seleccionarArchivo,
              child: Text('Seleccionar Archivo Excel'),
            ),
            SizedBox(height: 20),
            if (filePath != null) ...[
              Text('Archivo seleccionado: $filePath'),
              SizedBox(height: 20),
              Text("Vista previa de datos:"),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: List.generate(
                        excelData.isNotEmpty ? excelData[0].length : 0,
                            (index) => DataColumn(label: Text('Col $index')),
                      ),
                      rows: List.generate(
                        excelData.length,
                            (rowIndex) => DataRow(
                          selected: rowIndex == headerRow,
                          onSelectChanged: (selected) {
                            setState(() {
                              headerRow = selected! ? rowIndex : null;
                            });
                          },
                          cells: excelData[rowIndex]
                              .map((cell) => DataCell(Text(cell?.value.toString() ?? '')))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Dropdowns para seleccionar las columnas
              Text("Seleccionar columnas para cada encabezado:"),
              DropdownButton<int>(
                hint: Text("Seleccionar columna de Código"),
                value: codigoColumn,
                items: List.generate(excelData[0].length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text("Columna ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    codigoColumn = value;
                  });
                },
              ),
              DropdownButton<int>(
                hint: Text("Seleccionar columna de Descripción"),
                value: descripcionColumn,
                items: List.generate(excelData[0].length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text("Columna ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    descripcionColumn = value;
                  });
                },
              ),
              DropdownButton<int>(
                hint: Text("Seleccionar columna de Total"),
                value: totalColumn,
                items: List.generate(excelData[0].length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text("Columna ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    totalColumn = value;
                  });
                },
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (codigoColumn != null && descripcionColumn != null && totalColumn != null && headerRow != null)
                  ? crearNuevoExcel
                  : null,
              child: Text('Guardar Nuevo Archivo Excel'),
            ),
          ],
        ),
      ),
    );
  }
}
