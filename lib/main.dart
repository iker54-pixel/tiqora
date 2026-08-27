import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'services/notificaciones_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await NotificacionesService.instance.inicializar();
  runApp(const TiqoraApp());
}

class TiqoraApp extends StatelessWidget {
  const TiqoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiqora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      home: const HomeScreen(),
    );
  }
}
