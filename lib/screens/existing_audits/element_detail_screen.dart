import 'package:auditext/providers/auditoria/imagen_visual_provider.dart';
import 'package:auditext/providers/user_settings_provider.dart';
import 'package:auditext/screens/existing_audits/sections/analisis_dimensional_section.dart';
import 'package:auditext/screens/existing_audits/sections/defecto_visual_section.dart';
import 'package:auditext/screens/existing_audits/sections/element_info_section.dart';

import 'package:auditext/screens/existing_audits/sections/imagenes_sections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auditoria/elemento.dart';

class ElementDetailScreen extends StatelessWidget {
  final Elemento elemento;

  const ElementDetailScreen({super.key, required this.elemento});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImagenVisualProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Detalles: ${elemento.codigo}'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Información general'),
                Tab(text: 'Imagenes'),
                //Tab(text: 'Imagen Visual'),
                Tab(text: 'Defecto Visual'),
                Tab(text: 'Análisis Dimensional'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ElementInfoSection(elementoId: elemento.id!),
              ImagenesSection(elementoId: elemento.id!),
              DefectoVisualSection(elementoId: elemento.id!),
              AnalisisDimensionalGroupedSection(elementoId: elemento.id!),
            ],
          ),
        ),
      ),
    );
  }
}
