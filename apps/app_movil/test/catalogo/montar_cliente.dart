import 'package:app_movil/app.dart';
import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../registro/dobles.dart';
import 'fabricas.dart';

/// Doble de [CatalogoRepositorio]: devuelve [catalogo], o lanza [error] si
/// no es null. Cuenta las cargas.
class CatalogoRepositorioFijo implements CatalogoRepositorio {
  CatalogoRepositorioFijo(this.catalogo);

  Catalogo catalogo;
  Object? error;
  int cargas = 0;

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
  }) async {
    cargas++;
    final fallo = error;
    if (fallo != null) throw fallo;
    return catalogo;
  }
}

/// Catálogo de las pruebas de pantalla: 4 productos en 2 categorías y 2
/// marcas; "Ron Blanco 1 L" está agotado. Ninguno tiene `imagenUrl`, así que
/// no hay llamadas de red.
Catalogo catalogoDePrueba() => Catalogo(
  categorias: [
    categoria('c1', nombre: 'Cervezas', orden: 1),
    categoria('c2', nombre: 'Rones', orden: 2),
  ],
  productos: [
    producto(
      'p1',
      nombre: 'Cerveza Rubia 630 ml',
      marca: 'Rubia',
      categoriaId: 'c1',
      stockFisico: 340 * 12,
      presentaciones: [
        presentacion(
          'p1-caja',
          productoId: 'p1',
          nombre: 'Caja x 12',
          factor: 12,
          precioBase: 6290,
          preciosVolumen: [volumen(10, 6050), volumen(50, 5800)],
        ),
      ],
    ),
    producto(
      'p2',
      nombre: 'Cerveza Negra 330 ml',
      marca: 'Rubia',
      categoriaId: 'c1',
      presentaciones: [
        presentacion(
          'p2-caja',
          productoId: 'p2',
          nombre: 'Caja x 24',
          precioBase: 4500,
        ),
      ],
    ),
    producto(
      'p3',
      nombre: 'Ron Añejo 750 ml',
      marca: 'Cartavio',
      categoriaId: 'c2',
      presentaciones: [
        presentacion(
          'p3-bot',
          productoId: 'p3',
          nombre: 'Botella',
          precioBase: 3990,
        ),
      ],
    ),
    producto(
      'p4',
      nombre: 'Ron Blanco 1 L',
      marca: 'Cartavio',
      categoriaId: 'c2',
      stockFisico: 0,
      presentaciones: [
        presentacion(
          'p4-bot',
          productoId: 'p4',
          nombre: 'Botella',
          precioBase: 2990,
        ),
      ],
    ),
  ],
  preciosLista: const {},
);

/// Monta la app completa (router, barra y avisos reales) con una bodega
/// activa y [repositorio], y navega a [ubicacion]. Sin reintentos
/// automáticos de Riverpod, para que un error quede a la vista.
Future<({GoRouter router, ProviderContainer container})> montarCliente(
  WidgetTester tester, {
  required CatalogoRepositorio repositorio,
  String ubicacion = AppRutas.catalogo,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final bodega = membresia('d1');
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      controlAccesoProvider.overrideWith(
        () =>
            ControlAccesoFalso(ConAcceso(membresias: [bodega], activa: bodega)),
      ),
      catalogoRepositorioProvider.overrideWithValue(repositorio),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AppMovil()),
  );
  await tester.pumpAndSettle();
  final router = container.read(appRouterProvider);
  router.go(ubicacion);
  await tester.pumpAndSettle();
  return (router: router, container: container);
}

/// Deja pasar el tiempo de un SnackBar para que no quede un temporizador
/// pendiente al terminar la prueba.
Future<void> dejarPasarAviso(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpAndSettle();
}
