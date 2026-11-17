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
import '../shared/widgets/sin_rol_screen.dart';
import 'destino.dart';
import 'refresh_stream.dart';

part 'app_router.g.dart';

/// Rol leído de `app_metadata` (solo lo escribe el servidor, nunca el cliente).
/// TODO(contrato): confirmar con Jair cómo se asigna el rol (hook de Auth o tabla usuarios).
RolUsuario? _rolDe(Session? sesion) {
  final valor = sesion?.user.appMetadata['rol'];
  if (valor is! String) return null;
  return RolUsuario.values.asNameMap()[valor];
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRutas.auth,
    refreshListenable: RefrescoDesdeStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) {
      final sesion = supabase.auth.currentSession;
      return destinoRedireccion(
        haySesion: sesion != null,
        rol: _rolDe(sesion),
        ubicacion: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: AppRutas.auth, builder: (_, _) => const AuthScreen()),
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
