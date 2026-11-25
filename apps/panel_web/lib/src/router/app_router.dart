import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/rutas.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/clientes/presentation/clientes_screen.dart';
import '../features/configuracion/presentation/configuracion_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/disponibilidad/presentation/disponibilidad_screen.dart';
import '../features/invitaciones/presentation/invitaciones_screen.dart';
import '../features/pedidos/presentation/pedidos_screen.dart';
import '../features/productos/presentation/productos_screen.dart';
import '../features/reportes/presentation/reportes_screen.dart';
import '../features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import '../features/sesion/presentation/cargando_screen.dart';
import '../features/sesion/presentation/control_acceso.dart';
import '../features/sesion/presentation/error_acceso_screen.dart';
import '../shared/widgets/panel_shell.dart';
import '../shared/widgets/sin_acceso_screen.dart';
import 'destino.dart';

part 'app_router.g.dart';

/// Avisa a go_router que vuelva a evaluar `redirect`.
class _Refresco extends ChangeNotifier {
  void avisar() => notifyListeners();
}

/// Sección del panel: sin animación al cambiar, como una web.
GoRoute _seccion(String ruta, Widget pantalla) => GoRoute(
  path: ruta,
  pageBuilder: (_, state) =>
      NoTransitionPage<void>(key: state.pageKey, child: pantalla),
);

@riverpod
GoRouter appRouter(Ref ref) {
  final refresco = _Refresco();
  // `listen`, no `watch`: el router no se reconstruye; solo re-evalúa
  // `redirect` cuando cambia el acceso.
  ref.listen(controlAccesoProvider, (_, _) => refresco.avisar());

  final router = GoRouter(
    initialLocation: AppRutas.dashboard,
    refreshListenable: refresco,
    redirect: (context, state) {
      return destinoRedireccion(
        acceso: ref.read(controlAccesoProvider),
        ubicacion: state.matchedLocation,
        desde: state.uri.queryParameters[parametroDesde],
      );
    },
    routes: [
      GoRoute(path: AppRutas.auth, builder: (_, _) => const AuthScreen()),
      GoRoute(
        path: AppRutas.cargando,
        builder: (_, _) => const CargandoScreen(),
      ),
      GoRoute(
        path: AppRutas.errorAcceso,
        builder: (_, _) => const ErrorAccesoScreen(),
      ),
      GoRoute(
        path: AppRutas.sinAcceso,
        builder: (_, _) => const SinAccesoScreen(),
      ),
      GoRoute(
        path: AppRutas.seleccionDistribuidor,
        builder: (_, state) => SeleccionDistribuidorScreen(
          desde: state.uri.queryParameters[parametroDesde],
        ),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            PanelShell(ubicacion: state.matchedLocation, child: child),
        routes: [
          _seccion(AppRutas.dashboard, const DashboardScreen()),
          _seccion(AppRutas.productos, const ProductosScreen()),
          _seccion(AppRutas.disponibilidad, const DisponibilidadScreen()),
          _seccion(AppRutas.clientes, const ClientesScreen()),
          _seccion(AppRutas.invitaciones, const InvitacionesScreen()),
          _seccion(AppRutas.pedidos, const PedidosScreen()),
          _seccion(AppRutas.reportes, const ReportesScreen()),
          _seccion(AppRutas.configuracion, const ConfiguracionScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresco.dispose();
  });
  return router;
}
