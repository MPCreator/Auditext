import 'package:auditext/providers/auditoria/analisis_dimensional_provider.dart';
import 'package:auditext/providers/auditoria/auditoria_provider.dart';
import 'package:auditext/providers/auditoria/defecto_visual_provider.dart';
import 'package:auditext/providers/auditoria/elemento_provider.dart';
import 'package:auditext/providers/auditoria/imagen_empaque_provider.dart';
import 'package:auditext/providers/auditoria/imagen_medida_provider.dart';
import 'package:auditext/providers/auditoria/imagen_visual_provider.dart';
import 'package:auditext/providers/color_provider.dart';
import 'package:auditext/providers/defecto_provider.dart';
import 'package:auditext/providers/descripcion_provider.dart';
import 'package:auditext/providers/estilo_provider.dart';
import 'package:auditext/providers/inspeccion/inspeccion_provider.dart';
import 'package:auditext/providers/inspeccion/margen_error_provider.dart';
import 'package:auditext/providers/inspeccion/nivel_inspeccion_provider.dart';
import 'package:auditext/providers/inspeccion/nqa_provider.dart';
import 'package:auditext/providers/inspeccion/tipo_inspeccion_provider.dart';
import 'package:auditext/providers/talla_provider.dart';
import 'package:auditext/providers/tolerancia_provider.dart';
import 'package:auditext/providers/user_settings_provider.dart';
import 'package:auditext/services/db/database_manager.dart';
import 'package:auditext/utils/routes/app_routes.dart';
import 'package:auditext/utils/routes/route_names.dart';
import 'package:auditext/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la base de datos
  final dbManager = DatabaseManager();
  await dbManager.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorProvider()),
        ChangeNotifierProvider(create: (_) => TallaProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MargenErrorProvider()),
        ChangeNotifierProvider(create: (_) => TipoInspeccionProvider()),
        ChangeNotifierProvider(create: (_) => NivelInspeccionProvider()),
        ChangeNotifierProvider(create: (_) => NqaProvider()),
        ChangeNotifierProvider(create: (_) => InspeccionProvider()),
        ChangeNotifierProvider(create: (_) => EstiloProvider()),
        ChangeNotifierProvider(create: (_) => DescripcionProvider()),
        ChangeNotifierProvider(create: (_) => ToleranciaProvider()),
        ChangeNotifierProvider(create: (_) => AuditoriaProvider()),
        ChangeNotifierProvider(create: (_) => ElementoProvider()),
        ChangeNotifierProvider(create: (_) => DefectoProvider()),
        ChangeNotifierProvider(create: (_) => ImagenEmpaqueProvider()),
        ChangeNotifierProvider(create: (_) => ImagenVisualProvider()),
        ChangeNotifierProvider(create: (_) => ImagenMedidaProvider()),
        ChangeNotifierProvider(create: (_) => AnalisisDimensionalProvider()),
        ChangeNotifierProvider(create: (_) => DefectoVisualProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: RouteNames.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
