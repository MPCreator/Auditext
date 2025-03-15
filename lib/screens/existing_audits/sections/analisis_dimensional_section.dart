import 'dart:convert';
import 'package:auditext/providers/descripcion_provider.dart';
import 'package:auditext/providers/estilo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/auditoria/analisis_dimensional.dart';
import '../../../models/auditoria/elemento.dart';
import '../../../providers/auditoria/analisis_dimensional_provider.dart';
import '../../../providers/auditoria/elemento_provider.dart';
import '../../../providers/tolerancia_provider.dart';
import '../../../providers/talla_provider.dart';
import '../../../services/data_processing/audit_evaluation_service.dart';

class AnalisisDimensionalGroupedSection extends StatefulWidget {
  final int elementoId;
  const AnalisisDimensionalGroupedSection({Key? key, required this.elementoId})
      : super(key: key);

  @override
  _AnalisisDimensionalGroupedSectionState createState() =>
      _AnalisisDimensionalGroupedSectionState();
}

class _AnalisisDimensionalGroupedSectionState
    extends State<AnalisisDimensionalGroupedSection> {
  @override
  void initState() {
    super.initState();
    // Se obtienen los análisis asociados al elemento.
    Provider.of<AnalisisDimensionalProvider>(context, listen: false)
        .fetchAnalisisDimensionalByElementoId(widget.elementoId);
  }

  @override
  Widget build(BuildContext context) {
    final analisisProvider =
    Provider.of<AnalisisDimensionalProvider>(context, listen: true);
    final elementoProvider =
    Provider.of<ElementoProvider>(context, listen: true);
    final toleranciaProvider =
    Provider.of<ToleranciaProvider>(context, listen: false);
    final tallaProvider = Provider.of<TallaProvider>(context, listen: false);
    final estiloProvider = Provider.of<EstiloProvider>(context, listen: false);
    final descripcionProvider =
    Provider.of<DescripcionProvider>(context, listen: false);

    // Se obtiene (o se crea) el elemento.
    final elemento = elementoProvider.elementos.firstWhere(
          (e) => e.id == widget.elementoId,
      orElse: () => Elemento(
        id: widget.elementoId,
        auditoriaId: null,
        codigo: '',
        descripcion: '',
        totalGeneral: 0,
        totalAuditar: 0,
        tallas: {
          '2-4': 0,
          '4-6': 0,
          '6-8': 0,
          '8-10': 0,
          '10-12': 0,
          '12-14': 0,
          '14-16': 0,
          'S': 0,
          'M': 0,
          'L': 0,
          'SM': 0,
          'ML': 0,
          'M-L': 0,
          'XL': 0,
          'TU': 0,
        },
        colores: {'Rojo': 0, 'Azul': 0},
        nota: '',
      ),
    );

    Future<void> llamarGenerarToleranciasJson() async {
      final int? id = await estiloProvider.getEstiloIdByNombre(elemento.codigo);
      if (id == null) {
        print("No se encontró el estilo para el código: ${elemento.codigo}");
        return;
      }
      final Map<String, String> descripcionMapping =
      await descripcionProvider.getDescripcionMapping();
      final jsonMap = await toleranciaProvider.generarToleranciasJson(
        estiloId: id,
        tallaProvider: tallaProvider,
        tallasInvolucradas: elemento.tallas,
        descripcionMapping: descripcionMapping,
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        tallaProvider.fetchTallas(),
        estiloProvider.getEstiloIdByNombre(elemento.codigo).then((id) {
          return toleranciaProvider
              .getDescripcionesUnicasListByEstiloId(id ?? 0);
        }),
        estiloProvider.getEstiloIdByNombre(elemento.codigo).then((id) {
          return toleranciaProvider.getToleranciaByEstiloId(id ?? 0);
        }),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<String> descripciones = snapshot.data![1] as List<String>;
        final Map<String, dynamic>? toleranciaRecord =
        snapshot.data![2] as Map<String, dynamic>?;

        Map<String, dynamic> toleranciaMap = toleranciaRecord ?? {};
        if (toleranciaRecord != null && toleranciaRecord["datos"] != null) {
          try {
            toleranciaMap = json.decode(toleranciaRecord["datos"]);
          } catch (e) {
            debugPrint('Error al parsear la tolerancia: $e');
          }
        }

        final Map<String, String> tallasMapping = {
          for (var t in tallaProvider.tallas) t.rango: t.id.toString(),
        };

        Map<String, Map<String, Map<String, List<AnalisisDimensional>>>>
        grouped = {};
        for (var analisis in analisisProvider.AnalisisDimensionals) {
          final desc = analisis.toleranciaDescripcion;
          final talla = analisis.talla;
          final color = analisis.color;
          grouped.putIfAbsent(desc, () => {});
          grouped[desc]!.putIfAbsent(talla, () => {});
          grouped[desc]![talla]!.putIfAbsent(color, () => []);
          grouped[desc]![talla]![color]!.add(analisis);
        }

        llamarGenerarToleranciasJson();

        // Generamos una lista de tarjetas: una por cada descripción.
        List<Widget> cards = [];
        for (String descripcion in descripciones) {
          cards.add(Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descripcion,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ...elemento.tallas.keys.map((tallaKey) {
                    final String tallaId = tallasMapping[tallaKey] ?? tallaKey;
                    final toleranciaValor = toleranciaMap[tallaId] != null
                        ? toleranciaMap[tallaId][descripcion]
                        : null;

                    final String tallaTitulo = toleranciaValor != null
                        ? '$tallaKey ($toleranciaValor) ± ${(toleranciaValor * 0.05).toStringAsFixed(2)}'
                        : tallaKey;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tallaTitulo,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ...elemento.colores.keys.map((color) {
                            final List<AnalisisDimensional> listaAnalisis =
                                grouped[descripcion]?[tallaKey]?[color] ?? [];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$color:',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: listaAnalisis.map((analisis) {
                                        return Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(analisis.valor.toString()),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      size: 18),
                                                  onPressed: () {
                                                    _showValorDialog(
                                                      context,
                                                      isEditing: true,
                                                      analisisToEdit: analisis,
                                                      descripcion: descripcion,
                                                      talla: tallaKey,
                                                      color: color,
                                                      onSubmit: (valor) async {
                                                        final updatedAnalisis =
                                                        AnalisisDimensional(
                                                          id: analisis.id,
                                                          elementoId:
                                                          elemento.id!,
                                                          talla: tallaKey,
                                                          toleranciaDescripcion:
                                                          descripcion,
                                                          color: color,
                                                          valor: valor,
                                                        );
                                                        await analisisProvider
                                                            .updateAnalisisDimensional(
                                                            updatedAnalisis);
                                                      },
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      size: 18),
                                                  onPressed: () async {
                                                    if (analisis.id != null) {
                                                      await analisisProvider
                                                          .deleteAnalisisDimensional(
                                                          analisis.id!);
                                                    }
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _showValorDialog(
                                        context,
                                        isEditing: false,
                                        descripcion: descripcion,
                                        talla: tallaKey,
                                        color: color,
                                        onSubmit: (valor) async {
                                          final nuevoAnalisis =
                                          AnalisisDimensional(
                                            id: null,
                                            elementoId: elemento.id!,
                                            talla: tallaKey,
                                            toleranciaDescripcion: descripcion,
                                            color: color,
                                            valor: valor,
                                          );
                                          await analisisProvider
                                              .addAnalisisDimensional(
                                              nuevoAnalisis);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ));
        }

        // Envolvemos la vista final en una Column que muestra la evaluación en la parte superior.
        return Column(
          children: [
            FutureBuilder<String>(
              future: AuditDefectEvaluationService()
                  .evaluarAnalisisDimensional(widget.elementoId),
              builder: (context, evalSnapshot) {
                if (evalSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (evalSnapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Error evaluando análisis dimensional: ${evalSnapshot.error}",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                final result = evalSnapshot.data!;
                final resultColor =
                result == "APROBADO" ? Colors.green : Colors.red;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: resultColor),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: cards,
              ),
            ),
          ],
        );
      },
    );
  }
}


/// Diálogo para agregar/editar el valor (los demás datos se obtienen del contexto).
void _showValorDialog(
  BuildContext context, {
  required bool isEditing,
  AnalisisDimensional? analisisToEdit,
  required String descripcion,
  required String talla,
  required String color,
  required Future<void> Function(double valor) onSubmit,
}) {
  final _valorController = TextEditingController(
      text: isEditing ? analisisToEdit!.valor.toString() : '');
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(isEditing ? 'Editar Valor' : 'Agregar Valor'),
        content: TextField(
          controller: _valorController,
          decoration: const InputDecoration(labelText: 'Valor'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_valorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un valor')));
                return;
              }
              final valor = double.tryParse(_valorController.text);
              if (valor == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un valor numérico')));
                return;
              }
              await onSubmit(valor);
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
