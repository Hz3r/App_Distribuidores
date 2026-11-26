import 'dart:async';

import 'package:app_movil/src/shared/lectura_vigente.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('valorVigente', () {
    test('da el valor si es vigente y null si no o si no hay', () {
      expect(const AsyncData(5).valorVigente((v) => v == 5), 5);
      expect(const AsyncData(5).valorVigente((v) => v == 6), isNull);
      expect(const AsyncLoading<int>().valorVigente((_) => true), isNull);
    });
  });

  group('mostrarError', () {
    var fallos = 0;
    Future<int> fallar() async {
      fallos++;
      throw Exception('sin red');
    }

    setUp(() => fallos = 0);

    test(
      'un error que Riverpod reintenta solo se muestra como error',
      () async {
        final proveedor = FutureProvider<int>((_) => fallar());
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final primerError = Completer<AsyncValue<int>>();
        container.listen(proveedor, (_, lectura) {
          if (lectura.hasError && !primerError.isCompleted) {
            primerError.complete(lectura);
          }
        });

        // El futuro no falla mientras se reintenta: se mira el estado.
        final lectura = await primerError.future;
        expect(lectura.retrying, isTrue);
        expect(lectura.isLoading, isTrue);
        expect(lectura.mostrarError, isTrue);
      },
    );

    test('sin reintentos: error; al volver a pedirlo a mano, carga', () async {
      final proveedor = FutureProvider<int>(
        (_) => fallar(),
        retry: sinReintentos,
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(proveedor, (_, _) {});

      await expectLater(container.read(proveedor.future), throwsException);
      expect(container.read(proveedor).mostrarError, isTrue);
      expect(fallos, 1);

      container.invalidate(proveedor);
      final recargando = container.read(proveedor);
      expect(recargando.isLoading, isTrue);
      expect(recargando.mostrarError, isFalse);
    });
  });
}
