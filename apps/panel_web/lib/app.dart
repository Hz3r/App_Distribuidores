import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'src/config/tema_panel.dart';
import 'src/router/app_router.dart';

/// Raíz del panel web.
class PanelWeb extends ConsumerWidget {
  const PanelWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Panel del distribuidor',
      debugShowCheckedModeBanner: false,
      theme: temaPanel(),
      // Textos propios de los componentes (calendario, menús, tooltips) en
      // español.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
