import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/reportes/data/excel_pedidos.dart';
import 'package:panel_web/src/features/reportes/data/exportador_archivos.dart';
import 'package:panel_web/src/features/reportes/domain/periodo.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';

void main() {
  late String archivo;
  late Uint8List contenido;
  late String tipo;
  late ExportadorArchivos exportador;

  setUp(() {
    exportador = ExportadorArchivos(({
      required String nombre,
      required Uint8List bytes,
      required String tipoMime,
    }) async {
      archivo = nombre;
      contenido = bytes;
      tipo = tipoMime;
    });
  });

  test('exportarPedidos: xlsx con el periodo en el nombre', () async {
    await exportador.exportarPedidos(
      pedidos: [pedido('a', numero: 5), pedido('b', numero: 6)],
      nombreCliente: const {'c1': 'Bodega El Roble'},
      periodo: periodoEntre(DateTime(2026, 11), DateTime(2026, 11, 25)),
    );

    expect(archivo, 'pedidos_2026-11-01_a_2026-11-25.xlsx');
    expect(tipo, tipoXlsx);
    expect(
      Excel.decodeBytes(contenido).tables[hojaPedidos]!.rows,
      hasLength(3),
    );
  });

  test('descargarGuia: pdf con el número del pedido en el nombre', () async {
    await exportador.descargarGuia(
      pedido: pedido('a', numero: 1043),
      distribuidor: membresia('d1').distribuidor!,
      cliente: cliente('c1'),
    );

    expect(archivo, 'guia_pedido_1043.pdf');
    expect(tipo, tipoPdf);
    expect(latin1.decode(contenido.sublist(0, 4)), '%PDF');
  });
}
