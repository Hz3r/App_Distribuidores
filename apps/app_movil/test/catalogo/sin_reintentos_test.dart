import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/inicio/presentation/inicio_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../soporte/dobles_cliente.dart';
import 'montar_cliente.dart';

/// Con la política de reintentos por defecto de Riverpod (la de producción),
/// un fallo de lectura llega de inmediato a "Reintentar": el catálogo y el
/// resumen no se reintentan solos.
void main() {
  // El resumen lee con `.wait`, cuyo `ParallelWaitError` ya no se reintenta
  // con la política por defecto; la de cada provider no depende de eso.
  test('catálogo y resumen piden no reintentar ningún error', () {
    for (final retry in [
      catalogoProvider.retry,
      resumenComprasProvider.retry,
    ]) {
      expect(retry, isNotNull);
      expect(retry!(0, Exception('sin red')), isNull);
    }
  });

  testWidgets('catálogo: un fallo muestra "Reintentar" con una sola carga', (
    tester,
  ) async {
    final repositorio = CatalogoRepositorioFijo(catalogoDePrueba())
      ..error = Exception('sin red');

    await montarCliente(
      tester,
      repositorio: repositorio,
      reintentosPorDefecto: true,
    );

    expect(find.text('No pudimos cargar el catálogo.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(repositorio.cargas, 1);

    // Tampoco más tarde.
    await tester.pump(const Duration(minutes: 1));
    expect(repositorio.cargas, 1);
  });

  testWidgets('inicio: un fallo del resumen muestra "Reintentar" con una '
      'sola lectura', (tester) async {
    final pedidos = PedidosResumenRepositorioFijo()..error = Exception('x');

    await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      pedidos: pedidos,
      ubicacion: AppRutas.inicio,
      reintentosPorDefecto: true,
    );

    expect(find.text('Reintentar'), findsOneWidget);
    expect(pedidos.lecturas, hasLength(1));

    await tester.pump(const Duration(minutes: 1));
    expect(pedidos.lecturas, hasLength(1));
  });
}
