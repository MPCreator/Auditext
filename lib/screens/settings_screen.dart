import 'package:auditext/providers/descripcion_provider.dart';
import 'package:auditext/providers/estilo_provider.dart';
import 'package:auditext/providers/talla_provider.dart';
import 'package:auditext/providers/tolerancia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_settings.dart';
import '../providers/inspeccion/margen_error_provider.dart';
import '../providers/inspeccion/nivel_inspeccion_provider.dart';
import '../providers/inspeccion/nqa_provider.dart';
import '../providers/inspeccion/tipo_inspeccion_provider.dart';
import '../providers/user_settings_provider.dart';
import '../utils/routes/route_names.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TipoInspeccionProvider>(context, listen: false)
          .fetchTipoInspecciones();
      Provider.of<NivelInspeccionProvider>(context, listen: false)
          .fetchNivelInspecciones();
      Provider.of<NqaProvider>(context, listen: false).fetchNqas();
      Provider.of<MargenErrorProvider>(context, listen: false)
          .fetchMargenErrores();
      Provider.of<TallaProvider>(context, listen: false).fetchTallas();
      Provider.of<EstiloProvider>(context, listen: false).fetchEstilos();
      Provider.of<DescripcionProvider>(context, listen: false)
          .fetchDescripcions();
      Provider.of<ToleranciaProvider>(context, listen: false)
          .fetchTolerancias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final margenErrorProvider = Provider.of<MargenErrorProvider>(context);
    final tipoInspeccionProvider = Provider.of<TipoInspeccionProvider>(context);
    final nivelInspeccionProvider =
        Provider.of<NivelInspeccionProvider>(context);
    final nqaProvider = Provider.of<NqaProvider>(context);
    final tallaProvider = Provider.of<TallaProvider>(context);
    final estiloProvider = Provider.of<EstiloProvider>(context);
    final descripcionProvider = Provider.of<DescripcionProvider>(context);
    final toleranciaProvider = Provider.of<ToleranciaProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    Future<void> cargar() async {
      /*
      await toleranciaProvider.imprimirDatosEstiloDetallado(1,
          estiloProvider: estiloProvider,
          tallaProvider: tallaProvider,
          descripcionProvider: descripcionProvider);
          */
    }

    if (settingsProvider.settings == null) {
      settingsProvider.loadSettings();
      return const Center(child: CircularProgressIndicator());
    } else {
      cargar();
    }
    //toleranciaProvider.imprimirDatosEstilo(2);

    final UserSettings currentSettings = settingsProvider.settings!.first;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Configurar Auditorías')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*
            DropdownConfig(
              title: "Tipo de inspección",
              value: currentSettings.tipoInspeccionId,
              items: tipoInspeccionProvider.tipoInspecciones.map((t) => t.nombre).toList(),
              onChanged: (value) {
                final updated = currentSettings.copyWith(tipoInspeccion: value!);
                settingsProvider.saveSettings(updated);
              },
            ),
            DropdownConfig(
              title: "Nivel de inspección",
              value: currentSettings.nivelInspeccion,
              items: nivelInspeccionProvider.nivelInspecciones.map((n) => n.nombre).toList(),
              onChanged: (value) {
                final updated = currentSettings.copyWith(nivelInspeccion: value!);
                settingsProvider.saveSettings(updated);
              },
            ),
            DropdownConfig(
              title: "NQA",
              value: currentSettings.nqa,
              items: nqaProvider.nqas.map((n) => n.nombre).toList(),
              onChanged: (value) {
                final updated = currentSettings.copyWith(nqa: value!);
                settingsProvider.saveSettings(updated);
              },
            ),
            DropdownConfig(
              title: "Margen de error",
              value: currentSettings.margenError.toString(),
              items: margenErrorProvider.inspecciones
                  .map((m) => m.margen.toString())
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  final updated = currentSettings.copyWith(margenError: int.parse(value));
                  settingsProvider.saveSettings(updated);
                }
              },
            ),
            
            */

            EditButtons(
              onColoresTap: () {
                Navigator.of(context).pushNamed(RouteNames.settingsColor);
              },
              onTallasTap: () {
                Navigator.of(context).pushNamed(RouteNames.settingsTalla);
              },
              onToleranciasTap: () {
                // Acción para editar tolerancias
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Colors.blue.shade900,
                ),
                onPressed: () {
                  // Acción para guardar cambios
                },
                child: const Text(
                  "Guardar cambios",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DropdownConfig extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownConfig({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class EditButtons extends StatelessWidget {
  final VoidCallback onColoresTap;
  final VoidCallback onTallasTap;
  final VoidCallback onToleranciasTap;

  const EditButtons({
    super.key,
    required this.onColoresTap,
    required this.onTallasTap,
    required this.onToleranciasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditButtonRow(title: "Colores", onTap: onColoresTap),
        EditButtonRow(title: "Tallas", onTap: onTallasTap),
        EditButtonRow(title: "Tolerancias", onTap: onToleranciasTap),
      ],
    );
  }
}

class EditButtonRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const EditButtonRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: onTap,
            child: const Text("Editar"),
          ),
        ],
      ),
    );
  }
}
