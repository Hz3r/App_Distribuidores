import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

// Cada JSON reproduce una fila real de PostgREST: las mismas claves que las
// columnas de la tabla, incluida `actualizado_en`, que los modelos ignoran.

Map<String, dynamic> _filaDistribuidor() => <String, dynamic>{
  'id': 'd1',
  'nombre': 'Licores del Norte',
  'slug': 'licores-del-norte',
  'rubro': 'licores',
  'documento': null,
  'telefono': null,
  'estado': 'prueba',
  'moneda': 'PEN',
  'zona_horaria': 'America/Lima',
  'config_tema': <String, dynamic>{
    'nombre': 'Licores del Norte',
    'logo_url': 'https://ejemplo.test/logo.png',
    'color_primario': '#1F3A5F',
    'color_secundario': '#F2A900',
  },
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
};

Map<String, dynamic> _filaClienteNegocio({
  bool creditoHabilitado = false,
  int? limiteCreditoCentimos,
  int? plazoCreditoDias,
}) => <String, dynamic>{
  'id': 'c1',
  'distribuidor_id': 'd1',
  'nombre_negocio': 'Bodega Rosita',
  'documento': null,
  'direccion': 'Av. Uno 123',
  'referencia': null,
  'telefono': '999888777',
  'activo': true,
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
  'lista_precios_id': null,
  'credito_habilitado': creditoHabilitado,
  'limite_credito_centimos': limiteCreditoCentimos,
  'plazo_credito_dias': plazoCreditoDias,
};

Map<String, dynamic> _filaMembresia({
  required String rol,
  String? clienteNegocioId,
}) => <String, dynamic>{
  'id': 'm1',
  'perfil_id': 'u1',
  'distribuidor_id': 'd1',
  'rol': rol,
  'estado': 'activa',
  'cliente_negocio_id': clienteNegocioId,
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
};

Map<String, dynamic> _filaPresentacion({int factor = 12}) => <String, dynamic>{
  'id': 'pr1',
  'distribuidor_id': 'd1',
  'producto_id': 'p1',
  'nombre': 'Caja x12',
  'factor': factor,
  'precio_base_centimos': 32604,
  'orden': 0,
  'activo': true,
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
};

Map<String, dynamic> _filaPrecioVolumen() => <String, dynamic>{
  'id': 'pv1',
  'distribuidor_id': 'd1',
  'presentacion_id': 'pr1',
  'cantidad_minima': 5,
  'precio_centimos': 31000,
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
};

Map<String, dynamic> _filaPedido({
  String estado = 'recibido',
  String condicionPago = 'contado',
}) => <String, dynamic>{
  'id': 'p1',
  'distribuidor_id': 'd1',
  'numero': 7,
  'cliente_id': 'c1',
  'creado_por': 'u1',
  'repartidor_id': null,
  'estado': estado,
  'despacho': 'reparto',
  'direccion_entrega': 'Av. Uno 123',
  'nota_cliente': null,
  'total_centimos': 32604,
  'condicion_pago': condicionPago,
  'metodo_pago': null,
  'estado_pago': 'pendiente',
  'saldo_pendiente_centimos': 32604,
  'plazo_credito_dias': null,
  'vence_en': null,
  'motivo_cancelacion': null,
  'clave_idempotencia': 'k1',
  'entregado_en': null,
  'creado_en': '2026-11-22T18:00:00Z',
  'actualizado_en': '2026-11-22T18:00:00Z',
};

Map<String, dynamic> _filaPedidoItem(String id, String presentacionId) =>
    <String, dynamic>{
      'id': id,
      'distribuidor_id': 'd1',
      'pedido_id': 'p1',
      'presentacion_id': presentacionId,
      'producto_id': 'prod1',
      'nombre_producto': 'Ron Cartavio 7 años',
      'nombre_presentacion': 'Botella 750 ml',
      'factor': 1,
      'cantidad': 2,
      'precio_unitario_centimos': 4500,
      'subtotal_centimos': 9000,
      'creado_en': '2026-11-22T18:00:00Z',
    };

Map<String, dynamic> _filaPedidoEvento() => <String, dynamic>{
  'id': 'e1',
  'distribuidor_id': 'd1',
  'pedido_id': 'p1',
  'estado_anterior': null,
  'estado_nuevo': 'recibido',
  'hecho_por': 'u1',
  'nota': null,
  'creado_en': '2026-11-22T18:00:00Z',
};

void main() {
  group('Identidad y acceso', () {
    test('Distribuidor lee config_tema del contrato como ConfigTema', () {
      final distribuidor = Distribuidor.fromJson(_filaDistribuidor());

      expect(distribuidor.slug, 'licores-del-norte');
      expect(distribuidor.estado, EstadoDistribuidor.prueba);
      expect(distribuidor.zonaHoraria, 'America/Lima');
      expect(distribuidor.documento, isNull);
      expect(distribuidor.configTema.colorPrimario, '#1F3A5F');
      expect(distribuidor.configTema.logoUrl, 'https://ejemplo.test/logo.png');
      expect(distribuidor.toJson()['config_tema'], isA<Map<String, dynamic>>());
    });

    test('Perfil lee una fila de perfiles', () {
      final perfil = Perfil.fromJson(<String, dynamic>{
        'id': 'u1',
        'nombre': 'Rosa',
        'telefono': null,
        'es_super_admin': false,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(perfil.nombre, 'Rosa');
      expect(perfil.esSuperAdmin, isFalse);
      expect(perfil.telefono, isNull);
    });

    test('ClienteNegocio sin crédito deja nulos límite y plazo', () {
      final cliente = ClienteNegocio.fromJson(_filaClienteNegocio());

      expect(cliente.nombreNegocio, 'Bodega Rosita');
      expect(cliente.creditoHabilitado, isFalse);
      expect(cliente.limiteCreditoCentimos, isNull);
      expect(cliente.plazoCreditoDias, isNull);
      expect(cliente.listaPreciosId, isNull);
    });

    test('ClienteNegocio con crédito lee límite y plazo', () {
      final cliente = ClienteNegocio.fromJson(
        _filaClienteNegocio(
          creditoHabilitado: true,
          limiteCreditoCentimos: 500000,
          plazoCreditoDias: 15,
        ),
      );

      expect(cliente.creditoHabilitado, isTrue);
      expect(cliente.limiteCreditoCentimos, 500000);
      expect(cliente.plazoCreditoDias, 15);
    });

    test(
      'Membresia de cliente con distribuidor y cliente_negocio embebidos',
      () {
        final membresia = Membresia.fromJson(<String, dynamic>{
          ..._filaMembresia(rol: 'cliente', clienteNegocioId: 'c1'),
          'distribuidor': _filaDistribuidor(),
          'cliente_negocio': _filaClienteNegocio(),
        });

        expect(membresia.rol, RolMembresia.cliente);
        expect(membresia.estado, EstadoMembresia.activa);
        expect(membresia.estaActiva, isTrue);
        expect(membresia.clienteNegocioId, 'c1');
        expect(membresia.distribuidor?.nombre, 'Licores del Norte');
        expect(membresia.clienteNegocio?.nombreNegocio, 'Bodega Rosita');
      },
    );

    test('Membresia con distribuidor null deja la relación en null', () {
      final membresia = Membresia.fromJson(<String, dynamic>{
        ..._filaMembresia(rol: 'repartidor'),
        'estado': 'suspendida',
        'distribuidor': null,
      });

      expect(membresia.rol, RolMembresia.repartidor);
      expect(membresia.distribuidor, isNull);
      expect(membresia.clienteNegocio, isNull);
      expect(membresia.estaActiva, isFalse);
    });

    test('Invitacion lee una fila sin usar', () {
      final invitacion = Invitacion.fromJson(<String, dynamic>{
        'id': 'i1',
        'distribuidor_id': 'd1',
        'codigo': 'ABC123',
        'rol': 'vendedor',
        'cliente_negocio_id': null,
        'creada_por': 'u1',
        'vence_en': '2026-11-29T18:00:00Z',
        'usada_por': null,
        'usada_en': null,
        'revocada_en': null,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(invitacion.codigo, 'ABC123');
      expect(invitacion.rol, RolMembresia.vendedor);
      expect(invitacion.venceEn, DateTime.utc(2026, 11, 29, 18));
      expect(invitacion.usadaEn, isNull);
    });
  });

  group('Catálogo e inventario', () {
    test('Categoria lee una fila de categorias', () {
      final categoria = Categoria.fromJson(<String, dynamic>{
        'id': 'cat1',
        'distribuidor_id': 'd1',
        'nombre': 'Ron',
        'orden': 2,
        'activo': true,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(categoria.nombre, 'Ron');
      expect(categoria.orden, 2);
      expect(categoria.activo, isTrue);
    });

    test(
      'Producto sin categoría calcula stock disponible por presentación',
      () {
        final producto = Producto.fromJson(<String, dynamic>{
          'id': 'p1',
          'distribuidor_id': 'd1',
          'categoria_id': null,
          'nombre': 'Ron Cartavio 7 años',
          'descripcion': null,
          'marca': 'Cartavio',
          'sku': null,
          'imagen_url': null,
          'unidad_base': 'botella',
          'stock_fisico': 120,
          'stock_comprometido': 30,
          'activo': true,
          'creado_en': '2026-11-22T18:00:00Z',
          'actualizado_en': '2026-11-22T18:00:00Z',
          'presentaciones': <dynamic>[_filaPresentacion(factor: 12)],
        });

        expect(producto.categoriaId, isNull);
        expect(producto.stockDisponible, 90);
        expect(producto.presentaciones, hasLength(1));
        expect(producto.presentaciones.single.factor, 12);
        expect(producto.presentaciones.single.disponiblePara(producto), 7);
      },
    );

    test('Presentacion con precios_volumen embebidos', () {
      final presentacion = Presentacion.fromJson(<String, dynamic>{
        ..._filaPresentacion(),
        'precios_volumen': <dynamic>[_filaPrecioVolumen()],
      });

      expect(presentacion.precioBaseCentimos, 32604);
      expect(presentacion.preciosVolumen.single.cantidadMinima, 5);
    });

    test('Presentacion sin precios_volumen los deja vacíos', () {
      final presentacion = Presentacion.fromJson(_filaPresentacion());

      expect(presentacion.preciosVolumen, isEmpty);
      expect(presentacion.toJson()['precio_base_centimos'], 32604);
    });

    test('PrecioVolumen lee una fila de precios_volumen', () {
      final precio = PrecioVolumen.fromJson(_filaPrecioVolumen());

      expect(precio.distribuidorId, 'd1');
      expect(precio.precioCentimos, 31000);
    });

    test('ListaPrecios lee una fila de listas_precios', () {
      final lista = ListaPrecios.fromJson(<String, dynamic>{
        'id': 'l1',
        'distribuidor_id': 'd1',
        'nombre': 'Mayoristas',
        'activo': true,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(lista.nombre, 'Mayoristas');
    });

    test('PrecioLista lee una fila de precios_lista', () {
      final precio = PrecioLista.fromJson(<String, dynamic>{
        'id': 'pl1',
        'distribuidor_id': 'd1',
        'lista_precios_id': 'l1',
        'presentacion_id': 'pr1',
        'precio_centimos': 30000,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(precio.listaPreciosId, 'l1');
      expect(precio.precioCentimos, 30000);
    });

    test('MovimientoStock lee una reserva de pedido', () {
      final movimiento = MovimientoStock.fromJson(<String, dynamic>{
        'id': 'ms1',
        'distribuidor_id': 'd1',
        'producto_id': 'p1',
        'tipo': 'reserva',
        'delta_fisico': 0,
        'delta_comprometido': 12,
        'pedido_id': 'ped1',
        'hecho_por': null,
        'nota': null,
        'creado_en': '2026-11-22T18:00:00Z',
      });

      expect(movimiento.tipo, TipoMovimientoStock.reserva);
      expect(movimiento.deltaComprometido, 12);
      expect(movimiento.pedidoId, 'ped1');
    });
  });

  group('Pedidos', () {
    test('Pedido lee una fila de contado recién creada', () {
      final pedido = Pedido.fromJson(_filaPedido());

      expect(pedido.numero, 7);
      expect(pedido.despacho, DespachoPedido.reparto);
      expect(pedido.condicionPago, CondicionPago.contado);
      expect(pedido.metodoPago, isNull);
      expect(pedido.saldoPendienteCentimos, 32604);
      expect(pedido.items, isEmpty);
      expect(pedido.eventos, isEmpty);
      expect(pedido.toJson()['estado_pago'], 'pendiente');
    });

    test('Pedido a crédito entregado lee plazo y vencimiento', () {
      final pedido = Pedido.fromJson(<String, dynamic>{
        ..._filaPedido(estado: 'entregado', condicionPago: 'credito'),
        'plazo_credito_dias': 15,
        'vence_en': '2026-12-07',
        'entregado_en': '2026-11-22T20:00:00Z',
      });

      expect(pedido.estado, EstadoPedido.entregado);
      expect(pedido.condicionPago, CondicionPago.credito);
      expect(pedido.plazoCreditoDias, 15);
      expect(pedido.venceEn, DateTime(2026, 12, 7));
      expect(pedido.entregadoEn, DateTime.utc(2026, 11, 22, 20));
    });

    test('Pedido con items y eventos embebidos', () {
      final pedido = Pedido.fromJson(<String, dynamic>{
        ..._filaPedido(),
        'items': <dynamic>[
          _filaPedidoItem('it1', 'pr1'),
          _filaPedidoItem('it2', 'pr2'),
        ],
        'eventos': <dynamic>[_filaPedidoEvento()],
      });

      expect(pedido.items, hasLength(2));
      expect(pedido.items.last.presentacionId, 'pr2');
      expect(pedido.eventos, hasLength(1));
      expect(pedido.eventos.single.estadoNuevo, EstadoPedido.recibido);
    });

    test('Pedido con un estado desconocido lanza ArgumentError', () {
      expect(
        () => Pedido.fromJson(_filaPedido(estado: 'devuelto')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('PedidoItem guarda nombres y precio del momento de la compra', () {
      final item = PedidoItem.fromJson(_filaPedidoItem('it1', 'pr1'));

      expect(item.nombreProducto, 'Ron Cartavio 7 años');
      expect(item.precioUnitarioCentimos, 4500);
      expect(item.subtotalCentimos, 9000);
    });

    test('PedidoEvento lee estado anterior y nuevo', () {
      final evento = PedidoEvento.fromJson(<String, dynamic>{
        ..._filaPedidoEvento(),
        'estado_anterior': 'recibido',
        'estado_nuevo': 'en_camino',
      });

      expect(evento.estadoAnterior, EstadoPedido.recibido);
      expect(evento.estadoNuevo, EstadoPedido.enCamino);
      expect(PedidoEvento.fromJson(_filaPedidoEvento()).estadoAnterior, isNull);
    });
  });

  group('Cobros', () {
    test('Pago lee un cobro por billetera digital', () {
      final pago = Pago.fromJson(<String, dynamic>{
        'id': 'pg1',
        'distribuidor_id': 'd1',
        'pedido_id': 'p1',
        'cliente_id': 'c1',
        'monto_centimos': 10000,
        'metodo': 'billetera_digital',
        'referencia': 'OP-123',
        'nota': null,
        'registrado_por': 'u1',
        'anulado_en': null,
        'anulado_por': null,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(pago.metodo, MetodoPago.billeteraDigital);
      expect(pago.montoCentimos, 10000);
      expect(pago.anuladoEn, isNull);
      expect(pago.toJson()['metodo'], 'billetera_digital');
    });

    test('MetodoPago.billeteraDigital ida y vuelta con billetera_digital', () {
      final pedido = Pedido.fromJson(<String, dynamic>{
        ..._filaPedido(),
        'metodo_pago': 'billetera_digital',
      });

      expect(pedido.metodoPago, MetodoPago.billeteraDigital);
      expect(pedido.toJson()['metodo_pago'], 'billetera_digital');
      expect(
        Pedido.fromJson(pedido.toJson()).metodoPago,
        MetodoPago.billeteraDigital,
      );
    });
  });

  group('Plataforma', () {
    test('Plan lee límites jsonb como mapa', () {
      final plan = Plan.fromJson(<String, dynamic>{
        'id': 'pl1',
        'codigo': 'basico',
        'nombre': 'Básico',
        'precio_mensual_centimos': 9900,
        'moneda': 'PEN',
        'limites': <String, dynamic>{'productos': 200},
        'activo': true,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(plan.precioMensualCentimos, 9900);
      expect(plan.limites['productos'], 200);
    });

    test('Suscripcion lee periodos date', () {
      final suscripcion = Suscripcion.fromJson(<String, dynamic>{
        'id': 's1',
        'distribuidor_id': 'd1',
        'plan_id': 'pl1',
        'estado': 'prueba',
        'periodo_inicio': '2026-11-22',
        'periodo_fin': '2026-12-21',
        'proveedor_pago': null,
        'referencia_externa': null,
        'creado_en': '2026-11-22T18:00:00Z',
        'actualizado_en': '2026-11-22T18:00:00Z',
      });

      expect(suscripcion.estado, EstadoSuscripcion.prueba);
      expect(suscripcion.periodoInicio, DateTime(2026, 11, 22));
      expect(suscripcion.periodoFin, DateTime(2026, 12, 21));
    });

    test('PagoSuscripcion lee una fila de pagos_suscripcion', () {
      final pago = PagoSuscripcion.fromJson(<String, dynamic>{
        'id': 'ps1',
        'distribuidor_id': 'd1',
        'suscripcion_id': 's1',
        'monto_centimos': 9900,
        'metodo': 'transferencia',
        'periodo_inicio': '2026-11-22',
        'periodo_fin': '2026-12-21',
        'registrado_por': null,
        'referencia_externa': 'OP-9',
        'nota': null,
        'creado_en': '2026-11-22T18:00:00Z',
      });

      expect(pago.metodo, 'transferencia');
      expect(pago.montoCentimos, 9900);
      expect(pago.periodoFin, DateTime(2026, 12, 21));
    });
  });
}
