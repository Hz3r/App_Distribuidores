import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../sesion/acceso_fijo.dart';
import 'montar_cliente.dart';

/// Catálogo por bodega de un mismo distribuidor (`d1`): el de "Bodega Don
/// Pepe" (`cn-d1`, sin lista: Cerveza Rubia a S/ 62.90) llega al instante; el
/// de la otra bodega (`cn-otra`, con su lista: S/ 59.90) espera a que la
/// prueba complete [otra].
class CatalogoPorBodega implements CatalogoRepositorio {
  final otra = Completer<Catalogo>();
  final pedidas = <String?>[];

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
    required String? clienteNegocioId,
  }) {
    pedidas.add(clienteNegocioId);
    return clienteNegocioId == 'cn-otra'
        ? otra.future
        : Future.value(catalogoDePrueba());
  }
}

/// El catálogo de prueba con la lista de la otra bodega.
Catalogo catalogoDeOtraBodega() {
  final base = catalogoDePrueba();
  return Catalogo(
    distribuidorId: 'd1',
    clienteNegocioId: 'cn-otra',
    categorias: base.categorias,
    productos: base.productos,
    preciosLista: const {'p1-caja': 5990},
  );
}

void main() {
  final pepe = bodegaDePrueba();
  // Otra bodega del mismo distribuidor, con otra membresía y otra lista.
  final otra = pepe.copyWith(
    id: 'm-d1-otra',
    clienteNegocioId: 'cn-otra',
    clienteNegocio: pepe.clienteNegocio!.copyWith(
      id: 'cn-otra',
      nombreNegocio: 'Bodega La Esquina',
      listaPreciosId: 'lista-otra',
    ),
  );

  for (final ubicacion in [
    AppRutas.catalogo,
    AppRutas.detalleProducto('p1'),
    AppRutas.inicio,
  ]) {
    testWidgets('en $ubicacion, al pasar a otra bodega del mismo distribuidor '
        'no se ve ningún producto ni precio de la anterior mientras carga', (
      tester,
    ) async {
      final catalogos = CatalogoPorBodega();
      final control = ControlAccesoFijo(
        ConAcceso(membresias: [pepe, otra], activa: pepe),
      );
      final (router: _, :container) = await montarCliente(
        tester,
        repositorio: catalogos,
        control: control,
        ubicacion: ubicacion,
      );
      expect(find.textContaining('Cerveza Rubia'), findsWidgets);
      expect(find.textContaining('62.90'), findsWidgets);

      control.fijar(ConAcceso(membresias: [pepe, otra], activa: otra));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Cerveza Rubia'), findsNothing);
      expect(find.textContaining('62.90'), findsNothing);
      expect(find.textContaining('S/ '), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.widgetWithIcon(IconButton, Icons.add), findsNothing);

      expect(catalogos.pedidas, ['cn-d1', 'cn-otra']);

      catalogos.otra.complete(catalogoDeOtraBodega());
      await tester.pumpAndSettle();

      expect(find.textContaining('Cerveza Rubia'), findsWidgets);
      expect(find.textContaining('59.90'), findsWidgets);
      expect(find.textContaining('62.90'), findsNothing);
      expect(container.read(carritoActualProvider).lineas, 0);
    });
  }
}
