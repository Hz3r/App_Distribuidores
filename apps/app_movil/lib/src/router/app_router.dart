import 'package:core/core.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/rutas.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/carrito/presentation/carrito_screen.dart';
import '../features/catalogo/presentation/catalogo_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/perfil/presentation/perfil_screen.dart';
import '../features/pedidos/presentation/pedidos_screen.dart';
import '../features/repartidor/presentation/repartidor_screen.dart';
import '../features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import '../features/sesion/domain/acceso.dart';
import '../shared/widgets/pantalla_placeholder.dart';
import '../shared/widgets/sin_rol_screen.dart';
import 'destino.dart';
import 'refresh_stream.dart';

part 'app_router.g.dart';

/// Acceso provisional calculado solo con la sesión.
/// TODO(tarea 3): reemplazar por el provider que lee las membresías.
Acceso _accesoProvisional(Session? sesion) =>
    sesion == null ? const SinSesion() : const Cargando();

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRutas.auth,
    refreshListenable: RefrescoDesdeStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) {
      return destinoRedireccion(
        acceso: _accesoProvisional(supabase.auth.currentSession),
        ubicacion: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: AppRutas.auth, builder: (_, _) => const AuthScreen()),
      // Provisionales: la tarea 3 las reemplaza por sus pantallas reales.
      GoRoute(
        path: AppRutas.cargando,
        builder: (_, _) => const PantallaPlaceholder(
          titulo: 'Cargando',
          descripcion: 'Leyendo tus accesos…',
        ),
      ),
      GoRoute(
        path: AppRutas.errorAcceso,
        builder: (_, _) => const PantallaPlaceholder(
          titulo: 'Error',
          descripcion: 'No se pudieron leer tus accesos.',
        ),
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
}
