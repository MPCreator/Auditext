import 'package:auditext/services/report_creation/create_report_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/auditoria/auditoria.dart';
import '../../models/auditoria/elemento.dart';
import '../../providers/auditoria/auditoria_provider.dart';
import '../../providers/auditoria/elemento_provider.dart';
import '../../utils/routes/route_names.dart';
import '../new_audit/preauditoria_screen.dart';

class ElementListScreen extends StatelessWidget {
  final Auditoria auditoria;

  const ElementListScreen({super.key, required this.auditoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PO: ${auditoria.po}'),
      ),
      body: FutureBuilder(
        future: Provider.of<ElementoProvider>(context, listen: false)
            .fetchElementosByAuditoriaId(auditoria.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar elementos: ${snapshot.error}'),
            );
          }

          return Column(
            children: [
              _buildActionButtons(context),
              Expanded(
                child: Consumer<ElementoProvider>(
                  builder: (context, provider, child) {
                    final elementos = provider.elementos
                        .where(
                            (elemento) => elemento.auditoriaId == auditoria.id)
                        .toList();

                    if (elementos.isEmpty) {
                      return const Center(
                        child: Text('No hay elementos para esta auditoría.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: elementos.length,
                      itemBuilder: (context, index) {
                        final elemento = elementos[index];
                        return _buildElementoCard(context, elemento);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Descargar Excel'),
              onPressed: () => _exportToExcel(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Auditoría'),
              onPressed: () => _editAuditoria(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar Auditoría'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _deleteAuditoria(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementoCard(BuildContext context, Elemento elemento) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Center(child: Text(elemento.codigo)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteNames.elementDetail,
            arguments: elemento,
          );
        },
      ),
    );
  }

  void _exportToExcel(BuildContext context) async {
    // Solicitar permiso de almacenamiento
    final status = await Permission.storage.request();
    /*
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de almacenamiento denegado.'))
      );
      return;
    }

     */

    final CreateAuditReportService createReportService = CreateAuditReportService();
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Guardar antes del await
    final navigator = Navigator.of(context); // Guardar antes del await

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Iniciando creación de reportes')),
    );

    try {
      final downloadUrl = await createReportService.createAndExportAuditReports(auditoria);

      if (!context.mounted) return; // Evita usar un contexto obsoleto

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Descargar Reporte"),
            content: const Text("¿Deseas descargar el archivo comprimido?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  navigator.pop();
                },
              ),
              TextButton(
                child: const Text("Descargar"),
                onPressed: () async {
                  navigator.pop();
                  final uri = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    print("No se pudo abrir el enlace: $downloadUrl");
                  }
                },
              ),
            ],
          );
        },
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Exportación a Excel completa')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  void _editAuditoria(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreAuditoriaScreen(auditoriaId: auditoria.id!),
      ),
    );
  }

  void _deleteAuditoria(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta auditoría? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final auditoriaProvider =
                  Provider.of<AuditoriaProvider>(context, listen: false);
              await auditoriaProvider.deleteAuditoria(auditoria.id!);

              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Volver a la lista de auditorías

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auditoría eliminada')),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
