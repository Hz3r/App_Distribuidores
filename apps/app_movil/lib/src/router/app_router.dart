import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/rutas.dart';
import '../features/auth/presentation/ingreso_screen.dart';
import '../features/carrito/presentation/carrito_screen.dart';
import '../features/catalogo/presentation/catalogo_screen.dart';
import '../features/catalogo/presentation/detalle_producto_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/perfil/presentation/perfil_screen.dart';
import '../features/registro/domain/argumentos_registro.dart';
import '../features/registro/domain/codigo_por_canjear.dart';
import '../features/registro/presentation/bienvenida_screen.dart';
import '../features/registro/presentation/codigo_screen.dart';
import '../features/registro/presentation/registro_screen.dart';
import '../features/registro/presentation/revisa_correo_screen.dart';
import '../features/pedidos/presentation/pedidos_screen.dart';
import '../features/repartidor/presentation/repartidor_screen.dart';
import '../features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import '../features/sesion/presentation/cargando_screen.dart';
import '../features/sesion/presentation/control_acceso.dart';
import '../features/sesion/presentation/error_acceso_screen.dart';
import '../shared/widgets/pantalla_placeholder.dart';
import '../shared/widgets/sin_rol_screen.dart';
import 'destino.dart';
import 'estructura_cliente.dart';

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

  // Navegador raíz: lo que se abre en él (el detalle de producto) cubre la
  // barra inferior.
  final raiz = GlobalKey<NavigatorState>(debugLabel: 'raiz');

  final router = GoRouter(
    navigatorKey: raiz,
    initialLocation: AppRutas.bienvenida,
    refreshListenable: refresco,
    redirect: (context, state) {
      return destinoRedireccion(
        acceso: ref.read(controlAccesoProvider),
        ubicacion: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AppRutas.bienvenida,
        builder: (_, _) => const BienvenidaScreen(),
      ),
      GoRoute(path: AppRutas.codigo, builder: (_, _) => const CodigoScreen()),
      GoRoute(
        path: AppRutas.registro,
        // Sin el código validado no hay nada que registrar.
        redirect: (_, state) =>
            state.extra is ArgumentosRegistro ? null : AppRutas.codigo,
        builder: (_, state) =>
            RegistroScreen(argumentos: state.extra! as ArgumentosRegistro),
      ),
      GoRoute(
        path: AppRutas.revisaCorreo,
        // Recibe el correo por `extra`; sin él, la pantalla dice "tu correo".
        builder: (_, state) => RevisaCorreoScreen(
          correo: state.extra is String ? state.extra! as String : null,
        ),
      ),
      GoRoute(
        path: AppRutas.auth,
        // Desde el registro recibe el código por canjear al ingresar.
        builder: (_, state) => IngresoScreen(
          codigoPorCanjear: state.extra is CodigoPorCanjear
              ? state.extra! as CodigoPorCanjear
              : null,
        ),
      ),
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
      // Zona de la bodega con la barra inferior: una rama por pestaña, cada
      // una con su propia pila.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navegacion) =>
            EstructuraCliente(navegacion: navegacion),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRutas.inicio,
                builder: (_, _) => const PantallaPlaceholder(
                  titulo: 'Inicio',
                  descripcion: 'Resumen de tu negocio. Pendiente.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRutas.catalogo,
                builder: (_, _) => const CatalogoScreen(),
                routes: [
                  GoRoute(
                    path: 'producto/:id',
                    parentNavigatorKey: raiz,
                    builder: (_, state) => DetalleProductoScreen(
                      productoId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRutas.carrito,
                builder: (_, _) => const CarritoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRutas.pedidos,
                builder: (_, _) => const PedidosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRutas.perfil,
                builder: (_, _) => const PerfilScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRutas.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
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
