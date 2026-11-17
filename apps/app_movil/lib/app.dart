import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/router/app_router.dart';

/// Raíz de la app móvil. El tema se reemplazará con el ConfigTema del distribuidor.
class AppMovil extends ConsumerWidget {
  const AppMovil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Distribuidores',
      debugShowCheckedModeBanner: false,
      theme: ThemeBuilder.desde(const ConfigTema(nombre: 'Distribuidores')),
      routerConfig: router,
    );
  }
}
