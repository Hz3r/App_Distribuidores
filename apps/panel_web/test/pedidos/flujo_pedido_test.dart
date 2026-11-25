import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/pedidos/domain/flujo_pedido.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';

void main() {
  group('siguienteEstado', () {
    test('recibido pasa a confirmado', () {
      expect(siguienteEstado(pedido('p')), EstadoPedido.confirmado);
    });

    test('confirmado depende del despacho', () {
      expect(
        siguienteEstado(pedido('p', estado: EstadoPedido.confirmado)),
        EstadoPedido.enCamino,
      );
      expect(
        siguienteEstado(
          pedido(
            'p',
            estado: EstadoPedido.confirmado,
            despacho: DespachoPedido.recojo,
          ),
        ),
        EstadoPedido.listoRecojo,
      );
    });

    test('en camino y listo para recoger pasan a entregado', () {
      for (final estado in [EstadoPedido.enCamino, EstadoPedido.listoRecojo]) {
        expect(
          siguienteEstado(pedido('p', estado: estado)),
          EstadoPedido.entregado,
          reason: estado.name,
        );
      }
    });

    test('entregado y cancelado son finales: ni avanzan ni se cancelan', () {
      for (final estado in [EstadoPedido.entregado, EstadoPedido.cancelado]) {
        final p = pedido('p', estado: estado);
        expect(siguienteEstado(p), isNull, reason: estado.name);
        expect(sePuedeCancelar(p), isFalse, reason: estado.name);
      }
      expect(
        sePuedeCancelar(pedido('p', estado: EstadoPedido.enCamino)),
        isTrue,
      );
    });
  });

  test('grupoDe junta en camino con listo para recoger', () {
    expect(grupoDe(EstadoPedido.recibido), GrupoPedidos.porConfirmar);
    expect(grupoDe(EstadoPedido.enCamino), GrupoPedidos.enCamino);
    expect(grupoDe(EstadoPedido.listoRecojo), GrupoPedidos.enCamino);
    expect(grupoDe(EstadoPedido.cancelado), GrupoPedidos.cancelados);
  });

  group('cobro', () {
    test('pagado es el total menos el saldo', () {
      expect(pagadoCentimos(pedido('p', total: 10000, saldo: 6000)), 4000);
    });

    test('se puede cobrar si queda saldo y no está cancelado', () {
      expect(sePuedeCobrar(pedido('p')), isTrue);
      expect(sePuedeCobrar(pedido('p', saldo: 0)), isFalse);
      expect(
        sePuedeCobrar(pedido('p', estado: EstadoPedido.cancelado)),
        isFalse,
      );
      // También después de entregado: es cuando se cobra el crédito.
      expect(
        sePuedeCobrar(pedido('p', estado: EstadoPedido.entregado)),
        isTrue,
      );
    });

    test('crédito vencido: pasó la fecha y sigue con saldo', () {
      final ayer = ahoraDePrueba.subtract(const Duration(days: 1));
      Pedido aCredito({DateTime? vence, int? saldo}) => pedido(
        'p',
        estado: EstadoPedido.entregado,
        condicion: CondicionPago.credito,
        venceEn: vence,
        saldo: saldo,
      );

      expect(creditoVencido(aCredito(vence: ayer), ahoraDePrueba), isTrue);
      // El mismo día del vencimiento todavía no está vencido.
      expect(
        creditoVencido(aCredito(vence: ahoraDePrueba), ahoraDePrueba),
        isFalse,
      );
      expect(
        creditoVencido(aCredito(vence: ayer, saldo: 0), ahoraDePrueba),
        isFalse,
      );
      expect(creditoVencido(aCredito(), ahoraDePrueba), isFalse);
    });
  });

  test('filtrarPedidos busca por número (con o sin #) y por cliente', () {
    final a = pedido('a', numero: 1043, clienteId: 'c1');
    final b = pedido('b', numero: 1050, clienteId: 'c2');
    const nombres = {'c1': 'Bodega El Roble', 'c2': 'Licorería La Esquina'};

    expect(filtrarPedidos([a, b], '', nombres), [a, b]);
    expect(filtrarPedidos([a, b], '#1043', nombres), [a]);
    expect(filtrarPedidos([a, b], '105', nombres), [b]);
    expect(filtrarPedidos([a, b], 'licoreria', nombres), [b]);
    expect(filtrarPedidos([a, b], 'nada', nombres), isEmpty);
  });

  group('precioEstimado', () {
    PrecioVolumen escala(int minima, int precio) => PrecioVolumen(
      id: 'v$minima',
      distribuidorId: 'd1',
      presentacionId: 'b',
      cantidadMinima: minima,
      precioCentimos: precio,
      creadoEn: DateTime.utc(2026),
    );

    test('sin precios por volumen cobra el precio base', () {
      expect(precioEstimado(presentacion('b', precio: 850), 100), 850);
    });

    test('aplica la escala más alta que la cantidad alcanza', () {
      final p = presentacion(
        'b',
        precio: 850,
      ).copyWith(preciosVolumen: [escala(12, 800), escala(50, 750)]);

      expect(precioEstimado(p, 11), 850);
      expect(precioEstimado(p, 12), 800);
      expect(precioEstimado(p, 49), 800);
      expect(precioEstimado(p, 50), 750);
    });

    test('un precio por volumen más caro que el base no se aplica', () {
      final p = presentacion(
        'b',
        precio: 850,
      ).copyWith(preciosVolumen: [escala(12, 900)]);

      expect(precioEstimado(p, 20), 850);
    });
  });

  test('nuevaClaveIdempotencia tiene forma de UUID v4 y no se repite', () {
    final forma = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final azar = Random(7);
    final claves = {for (var i = 0; i < 50; i++) nuevaClaveIdempotencia(azar)};

    expect(claves, hasLength(50));
    for (final clave in claves) {
      expect(forma.hasMatch(clave), isTrue, reason: clave);
    }
  });
}
