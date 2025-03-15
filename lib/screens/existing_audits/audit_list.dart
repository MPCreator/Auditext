import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auditoria/auditoria.dart';
import '../../providers/auditoria/auditoria_provider.dart';
import '../../utils/routes/route_names.dart';
import '../new_audit/preauditoria_screen.dart';

class AuditoriaListScreen extends StatelessWidget {
  const AuditoriaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Auditorías'),
      ),
      body: FutureBuilder(
        future: Provider.of<AuditoriaProvider>(context, listen: false).fetchAuditorias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Consumer<AuditoriaProvider>(
            builder: (context, provider, child) {
              final auditorias = provider.auditorias;
              if (auditorias.isEmpty) {
                return const Center(
                  child: Text('No hay auditorías disponibles.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: auditorias.length,
                itemBuilder: (context, index) {
                  final auditoria = auditorias[index];
                  return _buildAuditoriaCard(context, auditoria);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAuditoriaCard(BuildContext context, Auditoria auditoria) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(auditoria.marca),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proveedor: ${auditoria.proveedor}'),
            Text('PO: ${auditoria.po}'),
            Text('Fecha de Auditoría: ${auditoria.fechaAuditoria}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteNames.elementList,
            arguments: auditoria,
          );
        },
      ),
    );
  }
}
