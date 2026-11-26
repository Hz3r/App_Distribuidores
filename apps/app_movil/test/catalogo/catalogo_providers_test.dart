import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/catalogo/domain/filtros_catalogo.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/sesion_activa.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../registro/dobles.dart';
import '../sesion/acceso_fijo.dart';

/// Doble de [CatalogoRepositorio]: anota cada carga y devuelve un catálogo
/// vacío.
class CatalogoRepositorioDoble implements CatalogoRepositorio {
  final cargas = <(String, String?)>[];

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    String? listaPreciosId,
  }) async {
    cargas.add((distribuidorId, listaPreciosId));
    return const Catalogo(categorias: [], productos: [], preciosLista: {});
  }
}

Membresia _conLista(String distribuidorId, String? listaPreciosId) =>
    membresia(distribuidorId).copyWith(
      clienteNegocio: ClienteNegocio(
        id: 'cn-$distribuidorId',
        distribuidorId: distribuidorId,
        nombreNegocio: 'Bodega',
        activo: true,
        creadoEn: DateTime.utc(2026),
        listaPreciosId: listaPreciosId,
        creditoHabilitado: false,
      ),
    );

void main() {
  late ControlAccesoFijo control;
  late CatalogoRepositorioDoble repositorio;
  late ProviderContainer container;

  final d1 = _conLista('d1', 'lista-1');
  final d2 = _conLista('d2', null);

  setUp(() {
    control = ControlAccesoFijo(ConAcceso(membresias: [d1, d2], activa: d1));
    repositorio = CatalogoRepositorioDoble();
    container = ProviderContainer(
      overrides: [
        controlAccesoProvider.overrideWith(() => control),
        catalogoRepositorioProvider.overrideWithValue(repositorio),
      ],
    );
    // Inicia el control para que la prueba pueda cambiar el acceso con
    // `fijar` antes de leer otro provider.
    container.read(controlAccesoProvider);
  });

  tearDown(() => container.dispose());

  group('membresiaActiva', () {
    test('es la activa de ConAcceso', () {
      expect(container.read(membresiaActivaProvider), d1);
    });

    test('es null sin elegir, sin sesión o cargando', () {
      container.listen(membresiaActivaProvider, (_, _) {});
      for (final acceso in [
        ConAcceso(membresias: [d1, d2], activa: null),
        const SinSesion(),
        const Cargando(),
        const ErrorAcceso('x'),
      ]) {
        control.fijar(acceso);
        expect(container.read(membresiaActivaProvider), isNull);
      }
    });
  });

  group('catalogo', () {
    test('carga el distribuidor activo con la lista de su bodega', () async {
      await container.read(catalogoProvider.future);

      expect(repositorio.cargas, [('d1', 'lista-1')]);
    });

    test('se recarga al cambiar de distribuidor', () async {
      container.listen(catalogoProvider, (_, _) {});
      await container.read(catalogoProvider.future);

      control.fijar(ConAcceso(membresias: [d1, d2], activa: d2));
      await container.read(catalogoProvider.future);

      expect(repositorio.cargas, [('d1', 'lista-1'), ('d2', null)]);
    });

    test('ref.invalidate lo vuelve a cargar', () async {
      container.listen(catalogoProvider, (_, _) {});
      await container.read(catalogoProvider.future);

      container.invalidate(catalogoProvider);
      await container.read(catalogoProvider.future);

      expect(repositorio.cargas, hasLength(2));
    });

    test('sin membresía activa falla sin llamar al repositorio', () async {
      control.fijar(const SinSesion());

      await expectLater(
        container.read(catalogoProvider.future),
        throwsA(isA<StateError>()),
      );
      expect(repositorio.cargas, isEmpty);
    });
  });

  group('filtrosCatalogoActuales', () {
    test('empieza sin filtros y se cambia con fijar', () {
      container.listen(filtrosCatalogoActualesProvider, (_, _) {});
      expect(
        container.read(filtrosCatalogoActualesProvider),
        const FiltrosCatalogo(),
      );

      container
          .read(filtrosCatalogoActualesProvider.notifier)
          .fijar(const FiltrosCatalogo(categoriaId: 'ron'));

      expect(
        container.read(filtrosCatalogoActualesProvider),
        const FiltrosCatalogo(categoriaId: 'ron'),
      );
    });

    test('se conservan sin oyentes (inicio fija la categoría antes de abrir '
        'el catálogo)', () async {
      container
          .read(filtrosCatalogoActualesProvider.notifier)
          .fijar(const FiltrosCatalogo(categoriaId: 'ron'));
      await pumpEventQueue();

      expect(
        container.read(filtrosCatalogoActualesProvider),
        const FiltrosCatalogo(categoriaId: 'ron'),
      );
    });

    test('vuelven a empezar al cambiar de distribuidor', () {
      container.listen(filtrosCatalogoActualesProvider, (_, _) {});
      container
          .read(filtrosCatalogoActualesProvider.notifier)
          .fijar(const FiltrosCatalogo(marca: 'Cartavio'));

      control.fijar(ConAcceso(membresias: [d1, d2], activa: d2));

      expect(
        container.read(filtrosCatalogoActualesProvider),
        const FiltrosCatalogo(),
      );
    });
  });
}
