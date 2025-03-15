import 'package:auditext/models/auditoria/elemento.dart';
import 'package:auditext/screens/existing_audits/audit_list.dart';
import 'package:auditext/screens/existing_audits/element_detail_screen.dart';
import 'package:auditext/screens/new_audit/preauditoria_screen.dart';
import 'package:auditext/screens/settings/talla_setting.dart';
import 'package:flutter/material.dart';
import '../../models/auditoria/auditoria.dart';
import '../../screens/existing_audits/element_list.dart';
import '../../screens/home_screen.dart';
import '../../screens/new_audit/load_order_screen.dart';
import '../../screens/settings/color_setting.dart';
import '../../screens/settings_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.profile:
        //return MaterialPageRoute(builder: (_) => ProfileScreen());
      case RouteNames.loadOrder:
        return MaterialPageRoute(builder: (_) => LoadOrderScreen());
      case RouteNames.preauditoria:
        if (settings.arguments is int) {
          final auditoriaId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => PreAuditoriaScreen(auditoriaId: auditoriaId),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('No se proporcionó un ID válido para la auditoría'),
            ),
          ),
        );

      case RouteNames.auditList:
        return MaterialPageRoute(builder: (_) => const AuditoriaListScreen());
      case RouteNames.elementList:
        if (settings.arguments is Auditoria) {
          final auditoria = settings.arguments as Auditoria;
          return MaterialPageRoute(
            builder: (_) => ElementListScreen(auditoria: auditoria,),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('No se proporcionó un ID válido para la auditoría'),
            ),
          ),
        );
      case RouteNames.elementDetail:
        if (settings.arguments is Elemento) {
          final elemento = settings.arguments as Elemento;
          return MaterialPageRoute(
            builder: (_) => ElementDetailScreen(elemento: elemento,),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('No se proporcionó un ID válido para la auditoría'),
            ),
          ),
        );

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.settingsColor:
        return MaterialPageRoute(builder: (_) => const SettingsColorScreen());
      case RouteNames.settingsTalla:
        return MaterialPageRoute(builder: (_) => const SettingsTallaScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No hay ruta definida para ${settings.name}')),
          ),
        );
    }
  }
}