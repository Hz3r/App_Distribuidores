import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/reportes/data/guia_pdf.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';

/// El PDF sin comprimir, como texto, para buscar lo que se imprimió.
String comoTexto(Uint8List bytes) => latin1.decode(bytes);

/// Páginas del documento (los objetos `/Type /Page`, sin contar `/Pages`).
int paginas(String pdf) => RegExp(r'/Type\s*/Page\b').allMatches(pdf).length;

void main() {
  final distribuidor = membresia('d1').distribuidor!;

  Future<String> guia(Pedido pedido, {ClienteNegocio? para}) async {
    return comoTexto(
      await armarGuiaPdf(
        pedido: pedido,
        distribuidor: distribuidor,
        cliente: para,
        comprimir: false,
      ),
    );
  }

  test('genera un PDF de una página con los datos del pedido', () async {
    final pdf = await guia(
      pedido('a', numero: 1043, total: 15050, saldo: 5000),
      para: cliente(
        'c1',
        nombre: 'Bodega Roble',
        documento: '20123456789',
        telefono: '987654321',
      ),
    );

    expect(pdf, startsWith('%PDF'));
    expect(paginas(pdf), 1);
    for (final esperado in [
      '1043',
      'Roble',
      '20123456789',
      '987654321',
      'Lager',
      '150.50',
      '100.50',
      '50.00',
      'contado',
      'tributaria',
    ]) {
      expect(pdf, contains(esperado), reason: 'falta "$esperado"');
    }
  });

  test('comprimido por defecto: más liviano y sigue siendo un PDF', () async {
    final p = pedido('a');
    final comprimido = await armarGuiaPdf(
      pedido: p,
      distribuidor: distribuidor,
    );
    final legible = await armarGuiaPdf(
      pedido: p,
      distribuidor: distribuidor,
      comprimir: false,
    );

    expect(latin1.decode(comprimido.sublist(0, 4)), '%PDF');
    expect(comprimido.length, lessThan(legible.length));
  });

  test('un pedido largo sigue en más páginas', () async {
    final pdf = await guia(
      pedido(
        'a',
        items: [
          for (var i = 0; i < 90; i++)
            PedidoItem(
              id: 'i$i',
              distribuidorId: 'd1',
              pedidoId: 'a',
              presentacionId: 'pr$i',
              productoId: 'p$i',
              nombreProducto: 'Producto $i',
              nombrePresentacion: 'Botella',
              factor: 1,
              cantidad: 1,
              precioUnitarioCentimos: 100,
              subtotalCentimos: 100,
              creadoEn: ahoraDePrueba,
            ),
        ],
      ),
    );

    expect(paginas(pdf), greaterThan(1));
  });

  test('a crédito indica el vencimiento; cancelado no deja saldo', () async {
    final credito = await guia(
      pedido(
        'a',
        condicion: CondicionPago.credito,
        venceEn: DateTime(2026, 12, 10),
      ),
    );
    expect(credito, contains('vence'));
    expect(credito, contains('dic'));

    final cancelado = await guia(
      pedido('b', estado: EstadoPedido.cancelado, total: 7700),
    );
    expect(cancelado, contains('Cancelado'));
    // Total 77.00, pero nada por cobrar.
    expect('77.00'.allMatches(cancelado), hasLength(2));
    expect(cancelado, contains('0.00'));
  });

  test('sin cliente ni dirección, y con texto que la fuente no tiene, '
      'igual se genera', () async {
    final base = pedido('a', nota: 'Dejar en portería 🙂 – gracias');
    final pdf = await guia(base.copyWith(direccionEntrega: null));

    expect(pdf, startsWith('%PDF'));
    expect(pdf, contains('Cliente'));
  });
}
