import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/router/app_router.dart';

/// Raíz del panel web. El tema se reemplazará con el ConfigTema del distribuidor.
class PanelWeb extends ConsumerWidget {
  const PanelWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Panel del distribuidor',
      debugShowCheckedModeBanner: false,
      theme: ThemeBuilder.desde(const ConfigTema(nombre: 'Panel')),
      routerConfig: router,
    );
  }
}
