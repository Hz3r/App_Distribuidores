import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/sesion/domain/acceso.dart';
import 'src/features/sesion/presentation/control_acceso.dart';
import 'src/router/app_router.dart';
import 'src/shared/tema_app.dart';

/// Raíz de la app móvil. El tema se reemplazará con el ConfigTema del
/// distribuidor.
class AppMovil extends ConsumerStatefulWidget {
  const AppMovil({super.key});

  @override
  ConsumerState<AppMovil> createState() => _AppMovilState();
}

class _AppMovilState extends ConsumerState<AppMovil> {
  final _avisos = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // El aviso de una carga (por ejemplo, un código que no vinculó) cuando
    // la persona entra a una zona con acceso. Sin membresías lo muestra la
    // pantalla sin acceso.
    ref.listen(controlAccesoProvider, (_, acceso) {
      if (acceso is! ConAcceso || acceso.membresias.isEmpty) return;
      final aviso = acceso.aviso;
      if (aviso == null) return;
      _avisos.currentState?.showSnackBar(SnackBar(content: Text(aviso)));
    });

    return MaterialApp.router(
      title: 'Distribuidores',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      scaffoldMessengerKey: _avisos,
      routerConfig: router,
    );
  }
}
