import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/auditoria/elemento.dart';
import '../../../providers/auditoria/elemento_provider.dart';
import '../../../providers/inspeccion/inspeccion_provider.dart';
import '../../../providers/user_settings_provider.dart';
import '../../../services/data_processing/audit_calculator_service.dart';
import '../../../services/data_processing/audit_evaluation_service.dart';

class ElementInfoSection extends StatefulWidget {
  final int elementoId;

  const ElementInfoSection({Key? key, required this.elementoId}) : super(key: key);

  @override
  _ElementInfoSectionState createState() => _ElementInfoSectionState();
}

class _ElementInfoSectionState extends State<ElementInfoSection> {
  bool _isDescriptionExpanded = false;
  late TextEditingController _notaController;
  Map<String, double> _colorRatios = {};
  Map<String, double> _tallaRatios = {};

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final elementoProvider = Provider.of<ElementoProvider>(context, listen: false);
    final elemento = elementoProvider.elementos.firstWhere((e) => e.id == widget.elementoId);
    _notaController.text = elemento.nota ?? '';
    if (elemento.totalGeneral > 0) {
      _colorRatios = elemento.colores.map((key, value) => MapEntry(key, value / elemento.totalGeneral));
      _tallaRatios = elemento.tallas.map((key, value) => MapEntry(key, value / elemento.totalGeneral));
    }
  }


  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ElementoProvider>(
      builder: (context, elementoProvider, child) {
        final elemento =
        elementoProvider.elementos.firstWhere((e) => e.id == widget.elementoId);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Elemento',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Widget>(
                  future: _buildGeneralInfoCard(elemento),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return snapshot.data!;
                  },
                ),

                const SizedBox(height: 16),
                // Se dejan tallas y colores como estaban...
                const Text(
                  'Detalles por Colores',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailList(
                  elemento.colores,
                  'Colores',
                  elemento.totalGeneral,
                  elemento.totalAuditar,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Detalles por Tallas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailList(
                  elemento.tallas,
                  'Tallas',
                  elemento.totalGeneral,
                  elemento.totalAuditar,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget modificado para mostrar el Total General con icono de edición
  Future<Widget> _buildGeneralInfoCard(Elemento elemento) async {
    final auditService = AuditDefectEvaluationService();
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.loadSettings();
    final settings = settingsProvider.settings.first;
    final inspeccionProvider =
    Provider.of<InspeccionProvider>(context, listen: false);
    final auditCalculatorService =
    AuditCalculatorService(inspeccionProvider: inspeccionProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Código', elemento.codigo),
            _buildExpandableDescription('Descripción', elemento.descripcion),
            // Fila para Total General con ícono de edición (lápiz)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total General: ',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      ' ${elemento.totalGeneral}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        int? newTotalGeneral = await _showEditTotalGeneralDialog(elemento.totalGeneral);
                        if (newTotalGeneral != null) {
                          // Se recalcula el total a auditar usando el servicio
                          int? newTotalAuditar = await auditCalculatorService.getTamanoMuestra(
                            nqaId: settings.nqaId,
                            tipoInspeccionId: settings.tipoInspeccionId,
                            nivelInspeccionId: settings.nivelInspeccionId,
                            tamanoLote: newTotalGeneral,
                          );
                          newTotalAuditar = newTotalAuditar ?? 0;

                          // Si el nuevo total general es mayor a 0, se usan los ratios almacenados
                          if (newTotalGeneral > 0) {
                            elemento.colores = _colorRatios.map((key, ratio) =>
                                MapEntry(key, (newTotalGeneral * ratio).round())
                            );
                            elemento.tallas = _tallaRatios.map((key, ratio) =>
                                MapEntry(key, (newTotalGeneral * ratio).round())
                            );
                          } else {
                            // Si se ingresa 0, se definen las cantidades en 0
                            elemento.colores = elemento.colores.map((key, value) => MapEntry(key, 0));
                            elemento.tallas = elemento.tallas.map((key, value) => MapEntry(key, 0));
                          }

                          setState(() {
                            elemento.totalGeneral = newTotalGeneral;
                            elemento.totalAuditar = newTotalAuditar!;
                          });
                          await Provider.of<ElementoProvider>(context, listen: false).updateElemento(elemento);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Total General, detalles y Total a Auditar actualizados")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            _infoRow('Total a Auditar', elemento.totalAuditar.toString()),
            FutureBuilder<String>(
              future: auditService.evaluarAmbosCriterios(widget.elementoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasError) {
                  return _infoRow("Evaluación", "Error al obtener valores");
                }
                final resultado = snapshot.data!;
                final color = resultado == "APROBADO" ? Colors.green : Colors.red;
                return _infoRow(
                  "Evaluación",
                  resultado,
                  textColor: color,
                );
              },
            ),
            FutureBuilder<Map<String, int>>(
              future: AuditDefectEvaluationService().obtenerAprobarRechazar(elemento.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasError) {
                  return _infoRow("Aprobar/Rechazar", "Error al obtener valores");
                }
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Aprobar", data['aprobar'].toString()),
                    _infoRow("Rechazar", data['rechazar'].toString()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Notas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _notaController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Escribe las notas aquí...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    final elementoProvider =
                    Provider.of<ElementoProvider>(context, listen: false);
                    final elementoToUpdate = elementoProvider.elementos
                        .firstWhere((e) => e.id == widget.elementoId);
                    elementoToUpdate.nota = _notaController.text;
                    await elementoProvider.updateElemento(elementoToUpdate);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notas actualizadas")),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo para editar el Total General
  Future<int?> _showEditTotalGeneralDialog(int currentValue) async {
    final TextEditingController controller =
    TextEditingController(text: currentValue.toString());
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Total General"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Ingrese nuevo Total General (mínimo 1)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                int? newValue = int.tryParse(controller.text);
                if (newValue == null || newValue < 1) {
                  newValue = 1;
                }
                Navigator.of(context).pop(newValue);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }


  /// Widget para mostrar una fila de información (título y valor).
  Widget _infoRow(String title, String value, {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar la descripción expandible.
  Widget _buildExpandableDescription(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              value,
              maxLines: _isDescriptionExpanded ? null : 3,
              overflow: _isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Mantiene el widget original para la lista de detalles (tallas/colores)
  Widget _buildDetailList(
      Map<String, int> details,
      String category,
      int totalGeneral,
      int totalAuditar,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Encabezado de la tabla
            Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nombre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Cantidad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Auditar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Lista de detalles
            ...details.entries.map((entry) {
              final int cantidad = entry.value;
              final int cantidadAuditar = totalGeneral > 0
                  ? ((cantidad * totalAuditar) / totalGeneral).round()
                  : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        cantidad.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        cantidadAuditar.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
