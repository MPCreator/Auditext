import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/auditoria/defecto_visual.dart';
import '../../../models/auditoria/elemento.dart';
import '../../../models/defecto.dart';
import '../../../providers/auditoria/elemento_provider.dart';
import '../../../providers/defecto_provider.dart';
import '../../../providers/auditoria/defecto_visual_provider.dart';
import '../../../services/data_processing/audit_evaluation_service.dart';

class DefectoVisualSection extends StatefulWidget {
  final int elementoId;

  const DefectoVisualSection({super.key, required this.elementoId});

  @override
  State<DefectoVisualSection> createState() => _DefectoVisualSectionState();
}

class _DefectoVisualSectionState extends State<DefectoVisualSection> {
  late Future<void> _fetchDefectosFuture;

  @override
  void initState() {
    super.initState();
    _fetchDefectosFuture =
        Provider.of<DefectoProvider>(context, listen: false).fetchDefectos();
  }

  @override
  Widget build(BuildContext context) {
    final defectoProvider = Provider.of<DefectoProvider>(context);
    final elementoProvider = Provider.of<ElementoProvider>(context);
    final defectoVisualProvider =
    Provider.of<DefectoVisualProvider>(context, listen: false);

    // FutureBuilder para cargar datos iniciales (defectos y defectos visuales)
    return FutureBuilder(
      future: Future.wait([
        _fetchDefectosFuture,
        defectoVisualProvider.fetchDefectoVisualByElementoId(widget.elementoId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Obtener el elemento actual basado en elementoId
        final elemento = elementoProvider.elementos.firstWhere(
              (e) => e.id == widget.elementoId,
          orElse: () => Elemento(
            id: widget.elementoId,
            auditoriaId: null,
            codigo: '',
            descripcion: '',
            totalGeneral: 0,
            totalAuditar: 0,
            colores: {},
            tallas: {},
            nota: '',
          ),
        );

        return Consumer<DefectoVisualProvider>(
          builder: (context, provider, child) {
            final defectosVisuales = provider.DefectoVisuals;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FutureBuilder que llama al servicio de evaluación
                FutureBuilder<String>(
                  future: AuditDefectEvaluationService()
                      .evaluarDefectosVisuales(widget.elementoId),
                  builder: (context, evalSnapshot) {
                    if (evalSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (evalSnapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error evaluando defectos',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    final evaluationResult = evalSnapshot.data!;
                    final resultColor = evaluationResult == "APROBADO"
                        ? Colors.green
                        : Colors.red;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        evaluationResult,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    );
                  },
                ),
                // Botón para agregar defecto
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Defecto'),
                  onPressed: () {
                    _showAddDefectoDialog(
                      context,
                          (nuevoDefecto) async {
                        await defectoVisualProvider.addDefectoVisual(nuevoDefecto);
                      },
                      defectoProvider.defectos,
                      elemento,
                      isEditing: false,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Código')),
                        DataColumn(label: Text('Descripción')),
                        DataColumn(label: Text('Color')),
                        DataColumn(label: Text('Talla')),
                        DataColumn(label: Text('Origen / Zona')),
                        DataColumn(label: Text('Mayor')),
                        DataColumn(label: Text('Menor')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: defectosVisuales.asMap().entries.map((entry) {
                        final defecto = entry.value;
                        final total = defecto.mayor + defecto.menor;
                        return DataRow(
                          cells: [
                            DataCell(Text(defecto.codigo)),
                            DataCell(Text(defecto.descripcion)),
                            DataCell(Text(defecto.color)),
                            DataCell(Text(defecto.talla)),
                            DataCell(Text(defecto.origenZona)),
                            DataCell(Text(defecto.mayor.toString())),
                            DataCell(Text(defecto.menor.toString())),
                            DataCell(Text(total.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showAddDefectoDialog(
                                      context,
                                          (updatedDefecto) async {
                                        await defectoVisualProvider
                                            .updateDefectoVisual(updatedDefecto);
                                      },
                                      defectoProvider.defectos,
                                      elemento,
                                      isEditing: true,
                                      defectoToEdit: defecto,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await defectoVisualProvider
                                        .deleteDefectoVisual(defecto.id!);
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showAddDefectoDialog(
    BuildContext context,
    Function(DefectoVisual) onAdd,
    List<Defecto> defectos,
    Elemento elemento, {
      required bool isEditing,
      DefectoVisual? defectoToEdit,
    }) {
  String? selectedDefecto = defectoToEdit?.codigo;
  String? selectedColor = defectoToEdit?.color;
  String? selectedTalla = defectoToEdit?.talla;
  final _descripcionController =
  TextEditingController(text: defectoToEdit?.descripcion ?? '');
  final _origenZonaController =
  TextEditingController(text: defectoToEdit?.origenZona ?? '');
  final _mayorController =
  TextEditingController(text: defectoToEdit?.mayor.toString() ?? '');
  final _menorController =
  TextEditingController(text: defectoToEdit?.menor.toString() ?? '');

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
            isEditing ? 'Editar Defecto Visual' : 'Agregar Defecto Visual'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDefecto,
                onChanged: (value) {
                  selectedDefecto = value;
                },
                items: defectos
                    .map(
                      (defecto) => DropdownMenuItem<String>(
                    value: defecto.codigo,
                    child: Text('${defecto.codigo} - ${defecto.nombre}'),
                  ),
                )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              DropdownButtonFormField<String>(
                value: selectedColor,
                onChanged: (value) {
                  selectedColor = value;
                },
                items: elemento.colores.keys
                    .map(
                      (color) => DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  ),
                )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              DropdownButtonFormField<String>(
                value: selectedTalla,
                onChanged: (value) {
                  selectedTalla = value;
                },
                items: elemento.tallas.keys
                    .map(
                      (talla) => DropdownMenuItem<String>(
                    value: talla,
                    child: Text(talla),
                  ),
                )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Talla'),
              ),
              TextField(
                controller: _origenZonaController,
                decoration:
                const InputDecoration(labelText: 'Origen / Zona'),
              ),
              TextField(
                controller: _mayorController,
                decoration: const InputDecoration(labelText: 'Mayor'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _menorController,
                decoration: const InputDecoration(labelText: 'Menor'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDefecto == null ||
                  selectedColor == null ||
                  selectedTalla == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                      Text('Por favor llena todos los campos')),
                );
                return;
              }

              final defecto = DefectoVisual(
                id: defectoToEdit?.id,
                elementoId: elemento.id!,
                codigo: selectedDefecto!,
                descripcion: _descripcionController.text,
                color: selectedColor!,
                talla: selectedTalla!,
                origenZona: _origenZonaController.text,
                mayor: int.tryParse(_mayorController.text) ?? 0,
                menor: int.tryParse(_menorController.text) ?? 0,
              );
              onAdd(defecto);
              Navigator.of(ctx).pop();
            },
            child: Text(isEditing ? 'Guardar Cambios' : 'Agregar'),
          ),
        ],
      );
    },
  );
}
