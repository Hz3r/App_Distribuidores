import 'package:core/core.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/rutas.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/clientes/presentation/clientes_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/pedidos/presentation/pedidos_screen.dart';
import '../features/personalizacion/presentation/personalizacion_screen.dart';
import '../features/productos/presentation/productos_screen.dart';
import '../features/repartidores/presentation/repartidores_screen.dart';
import '../shared/widgets/sin_acceso_screen.dart';
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
      GoRoute(
        path: AppRutas.sinAcceso,
        builder: (_, _) => const SinAccesoScreen(),
      ),
      GoRoute(
        path: AppRutas.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRutas.productos,
        builder: (_, _) => const ProductosScreen(),
      ),
      GoRoute(path: AppRutas.pedidos, builder: (_, _) => const PedidosScreen()),
      GoRoute(
        path: AppRutas.clientes,
        builder: (_, _) => const ClientesScreen(),
      ),
      GoRoute(
        path: AppRutas.repartidores,
        builder: (_, _) => const RepartidoresScreen(),
      ),
      GoRoute(
        path: AppRutas.personalizacion,
        builder: (_, _) => const PersonalizacionScreen(),
      ),
    ],
  );
}
