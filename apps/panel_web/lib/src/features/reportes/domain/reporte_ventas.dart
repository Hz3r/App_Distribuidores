import 'package:core/core.dart';

/// Una fila de un desglose del reporte (un producto, un cliente o una
/// categoría).
class FilaReporte {
  const FilaReporte({
    required this.clave,
    required this.nombre,
    required this.centimos,
    required this.cantidad,
  });

  /// Id de lo que agrupa (producto, cliente o categoría).
  final String clave;
  final String nombre;

  /// Vendido en el periodo.
  final int centimos;

  /// Unidades base vendidas (productos y categorías) o pedidos (clientes).
  final int cantidad;
}

/// Ventas de un periodo. Una **venta** es un pedido no cancelado y cuenta
/// en la fecha en que se creó.
class ReporteVentas {
  const ReporteVentas({
    required this.ventasCentimos,
    required this.pedidos,
    required this.cancelados,
    required this.clientes,
    required this.porCobrarCentimos,
    required this.porProducto,
    required this.porCliente,
    required this.porCategoria,
  });

  final int ventasCentimos;

  /// Pedidos que cuentan como venta.
  final int pedidos;

  /// Pedidos cancelados del periodo (no cuentan como venta).
  final int cancelados;

  /// Clientes distintos que compraron.
  final int clientes;

  /// Lo que falta cobrar de las ventas del periodo.
  final int porCobrarCentimos;

  /// De mayor a menor venta.
  final List<FilaReporte> porProducto;
  final List<FilaReporte> porCliente;
  final List<FilaReporte> porCategoria;

  /// Venta promedio por pedido, en céntimos enteros; 0 si no hubo pedidos.
  int get ticketPromedioCentimos =>
      pedidos == 0 ? 0 : (ventasCentimos / pedidos).round();
}

/// Clave de los productos que no tienen categoría (o cuyo producto ya no
/// está en el catálogo).
const sinCategoria = '';

/// Arma el reporte con los pedidos del periodo (con sus líneas).
///
/// [categoriaDeProducto] dice a qué categoría pertenece hoy cada producto;
/// los nombres de producto salen de la copia guardada en el pedido, así un
/// producto renombrado o borrado del catálogo sigue apareciendo.
ReporteVentas armarReporte(
  List<Pedido> pedidos, {
  required Map<String, String> nombreCliente,
  required Map<String, String?> categoriaDeProducto,
  required Map<String, String> nombreCategoria,
}) {
  var ventas = 0;
  var cuenta = 0;
  var cancelados = 0;
  var porCobrar = 0;
  final productos = <String, _Suma>{};
  final clientes = <String, _Suma>{};
  final categorias = <String, _Suma>{};

  for (final pedido in pedidos) {
    if (pedido.estado == EstadoPedido.cancelado) {
      cancelados++;
      continue;
    }
    ventas += pedido.totalCentimos;
    cuenta++;
    porCobrar += pedido.saldoPendienteCentimos;
    clientes
        .putIfAbsent(
          pedido.clienteId,
          () => _Suma(nombreCliente[pedido.clienteId] ?? 'Cliente'),
        )
        .agregar(pedido.totalCentimos, 1);

    for (final item in pedido.items) {
      final unidades = item.cantidad * item.factor;
      productos
          .putIfAbsent(item.productoId, () => _Suma(item.nombreProducto))
          .agregar(item.subtotalCentimos, unidades);
      final categoria = categoriaDeProducto[item.productoId] ?? sinCategoria;
      categorias
          .putIfAbsent(
            categoria,
            () => _Suma(nombreCategoria[categoria] ?? 'Sin categoría'),
          )
          .agregar(item.subtotalCentimos, unidades);
    }
  }

  return ReporteVentas(
    ventasCentimos: ventas,
    pedidos: cuenta,
    cancelados: cancelados,
    clientes: clientes.length,
    porCobrarCentimos: porCobrar,
    porProducto: _filas(productos),
    porCliente: _filas(clientes),
    porCategoria: _filas(categorias),
  );
}

class _Suma {
  _Suma(this.nombre);

  final String nombre;
  int centimos = 0;
  int cantidad = 0;

  void agregar(int masCentimos, int masCantidad) {
    centimos += masCentimos;
    cantidad += masCantidad;
  }
}

/// De mayor a menor venta; a igual venta, por nombre.
List<FilaReporte> _filas(Map<String, _Suma> sumas) {
  return [
    for (final MapEntry(:key, :value) in sumas.entries)
      FilaReporte(
        clave: key,
        nombre: value.nombre,
        centimos: value.centimos,
        cantidad: value.cantidad,
      ),
  ]..sort((a, b) {
    final porVenta = b.centimos.compareTo(a.centimos);
    return porVenta != 0 ? porVenta : a.nombre.compareTo(b.nombre);
  });
}

/// Qué parte de [total] es [parte], en porcentaje entero; 0 si no hay total.
int porcentajeDe(int parte, int total) =>
    total <= 0 ? 0 : (parte * 100 / total).round();
