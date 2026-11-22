import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/rutas.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/carrito/presentation/carrito_screen.dart';
import '../features/catalogo/presentation/catalogo_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/perfil/presentation/perfil_screen.dart';
import '../features/pedidos/presentation/pedidos_screen.dart';
import '../features/repartidor/presentation/repartidor_screen.dart';
import '../features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import '../features/sesion/presentation/cargando_screen.dart';
import '../features/sesion/presentation/control_acceso.dart';
import '../features/sesion/presentation/error_acceso_screen.dart';
import '../shared/widgets/sin_rol_screen.dart';
import 'destino.dart';

part 'app_router.g.dart';

/// Avisa a go_router que vuelva a evaluar `redirect`.
class _Refresco extends ChangeNotifier {
  void avisar() => notifyListeners();
}

@riverpod
GoRouter appRouter(Ref ref) {
  final refresco = _Refresco();
  // `listen`, no `watch`: el router no se reconstruye; solo re-evalúa
  // `redirect` cuando cambia el acceso.
  ref.listen(controlAccesoProvider, (_, _) => refresco.avisar());

  final router = GoRouter(
    initialLocation: AppRutas.auth,
    refreshListenable: refresco,
    redirect: (context, state) {
      return destinoRedireccion(
        acceso: ref.read(controlAccesoProvider),
        ubicacion: state.matchedLocation,
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
      GoRoute(path: AppRutas.sinRol, builder: (_, _) => const SinRolScreen()),
      GoRoute(
        path: AppRutas.seleccionDistribuidor,
        builder: (_, _) => const SeleccionDistribuidorScreen(),
      ),
      GoRoute(
        path: AppRutas.catalogo,
        builder: (_, _) => const CatalogoScreen(),
      ),
      GoRoute(path: AppRutas.carrito, builder: (_, _) => const CarritoScreen()),
      GoRoute(
        path: AppRutas.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
      GoRoute(path: AppRutas.pedidos, builder: (_, _) => const PedidosScreen()),
      GoRoute(path: AppRutas.perfil, builder: (_, _) => const PerfilScreen()),
      GoRoute(
        path: AppRutas.repartidor,
        builder: (_, _) => const RepartidorScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresco.dispose();
  });
  return router;
}
