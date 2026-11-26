import 'package:app_movil/app.dart';
import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/inicio/domain/pedidos_resumen_repositorio.dart';
import 'package:app_movil/src/features/inicio/presentation/inicio_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/router/app_router.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:material_ui/material_ui.dart';

import '../registro/dobles.dart';
import '../soporte/dobles_cliente.dart';
import 'fabricas.dart';

/// Catálogo de las pruebas de pantalla: 4 productos en 2 categorías y 2
/// marcas; "Ron Blanco 1 L" está agotado. Ninguno tiene `imagenUrl`, así que
/// no hay llamadas de red.
Catalogo catalogoDePrueba() => Catalogo(
  distribuidorId: 'd1',
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

/// Membresía de las pruebas de pantalla: la bodega "Bodega Don Pepe" del
/// distribuidor "Licores del Norte" (d1).
Membresia bodegaDePrueba() => membresia('d1').copyWith(
  clienteNegocioId: 'cn-d1',
  clienteNegocio: ClienteNegocio(
    id: 'cn-d1',
    distribuidorId: 'd1',
    nombreNegocio: 'Bodega Don Pepe',
    activo: true,
    creadoEn: DateTime.utc(2026),
    creditoHabilitado: false,
  ),
  distribuidor: membresia('d1').distribuidor!
      .copyWith(configTema: const ConfigTema(nombre: 'Licores del Norte')),
);

/// "Ahora" de las pruebas de pantalla: 26 de noviembre de 2026, 15:00 UTC.
final ahoraDePrueba = DateTime.utc(2026, 11, 26, 15);

/// Monta la app completa (router, barra y avisos reales) con una bodega
/// activa, [repositorio] y [pedidos] (sin pedidos si no se da), con el reloj
/// en [ahoraDePrueba], y navega a [ubicacion], en un teléfono de [ancho]
/// puntos lógicos. [control] reemplaza el acceso fijo de la bodega (por
/// ejemplo, para cambiar de membresía durante la prueba).
///
/// Sin reintentos automáticos de Riverpod, para que un error quede a la
/// vista; con [reintentosPorDefecto] el contenedor usa la política por
/// defecto, como en producción.
Future<({GoRouter router, ProviderContainer container})> montarCliente(
  WidgetTester tester, {
  required CatalogoRepositorio repositorio,
  PedidosResumenRepositorio? pedidos,
  String ubicacion = AppRutas.catalogo,
  double ancho = 390,
  ControlAcceso? control,
  bool reintentosPorDefecto = false,
}) async {
  tester.view.physicalSize = Size(ancho * 3, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final bodega = bodegaDePrueba();
  final container = ProviderContainer(
    retry: reintentosPorDefecto ? null : (_, _) => null,
    overrides: [
      controlAccesoProvider.overrideWith(
        () =>
            control ??
            ControlAccesoFalso(ConAcceso(membresias: [bodega], activa: bodega)),
      ),
      catalogoRepositorioProvider.overrideWithValue(repositorio),
      pedidosResumenRepositorioProvider.overrideWithValue(
        pedidos ?? PedidosResumenRepositorioFijo(),
      ),
      relojProvider.overrideWithValue(() => ahoraDePrueba),
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

/// El texto [finder] se ve completo: no se cortó ni pasó de sus líneas.
void expectSinRecortar(WidgetTester tester, Finder finder) {
  final parrafo = tester.renderObject<RenderParagraph>(finder);
  expect(parrafo.didExceedMaxLines, isFalse, reason: '$finder se recorta');
}
