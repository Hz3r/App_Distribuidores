import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Ejecutar con: flutter run --dart-define-from-file=../../env/dev.json
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppEnv.estaConfigurado) {
    runApp(const PantallaConfigFaltante());
    return;
  }

  await inicializarSupabase();
  runApp(const ProviderScope(child: AppMovil()));
}
