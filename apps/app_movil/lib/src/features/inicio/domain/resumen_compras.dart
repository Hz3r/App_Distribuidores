import 'package:core/core.dart';

import '../../catalogo/domain/catalogo.dart';

/// Resumen de las compras de una bodega para la pantalla de inicio. Lógica
/// pura: sin Flutter ni Supabase.
class ResumenCompras {
  const ResumenCompras({
    required this.ultimoPedido,
    required this.compradoEsteMesCentimos,
    required this.compradoMesAnteriorCentimos,
    required this.variacionPorcentaje,
    required this.productosMasPedidos,
    required this.mesAnterior,
  });

  /// El más reciente, de cualquier estado y sin límite de fecha; `null` solo
  /// si la bodega nunca hizo un pedido.
  final Pedido? ultimoPedido;

  /// Suma de los totales del mes en curso, sin los cancelados.
  final int compradoEsteMesCentimos;

  /// Suma de los totales del mes anterior, sin los cancelados.
  final int compradoMesAnteriorCentimos;

  /// Contra el mes anterior, redondeado; `null` si ese mes fue 0. Puede ser
  /// 0 con totales distintos (menos de ±0.5 %): para decir "igual", comparar
  /// los totales.
  final int? variacionPorcentaje;

  /// Ids de producto, de más a menos unidades base, máximo
  /// [maxProductosMasPedidos].
  final List<String> productosMasPedidos;

  /// Mes anterior al de [compradoEsteMesCentimos] (1 = enero), para decir
  /// "vs octubre".
  final int mesAnterior;
}

/// Cuántos productos entran en "Lo que más pides".
const maxProductosMasPedidos = 6;

/// Días hacia atrás que cuentan para "Lo que más pides".
const diasMasPedidos = 90;

/// Desfase de la zona horaria del distribuidor respecto de UTC: el de
/// `America/Lima` (UTC−5, sin horario de verano).
///
/// Limitación: la app no tiene una base de datos de zonas horarias, así que
/// usa este desfase para cualquier `zonaHoraria` del distribuidor.
const desfaseZonaDistribuidor = Duration(hours: -5);

/// Desde cuándo hay que leer los pedidos para [resumirCompras]: 90 días
/// atrás o el inicio (en la zona del distribuidor) del mes anterior, lo que
/// sea más antiguo. En UTC.
DateTime desdeParaResumen({
  required DateTime ahora,
  Duration desfaseZona = const Duration(hours: -5),
}) {
  final local = ahora.toUtc().add(desfaseZona);
  // `DateTime.utc` acepta el mes 0 (diciembre del año anterior).
  final inicioMesAnterior = DateTime.utc(
    local.year,
    local.month - 1,
  ).subtract(desfaseZona);
  final hace90 = ahora.toUtc().subtract(const Duration(days: diasMasPedidos));
  return inicioMesAnterior.isBefore(hace90) ? inicioMesAnterior : hace90;
}

/// Resume [pedidos] (los recientes, ver [desdeParaResumen]) de una bodega.
/// [ultimoPedido] se lee aparte y sin límite de fecha: puede ser más viejo
/// que todos los de [pedidos].
///
/// [ahora] se pasa como parámetro para poder probar; los meses se cuentan
/// en la zona horaria [desfaseZona] del distribuidor (America/Lima = UTC−5).
ResumenCompras resumirCompras(
  List<Pedido> pedidos, {
  required Pedido? ultimoPedido,
  required DateTime ahora,
  Duration desfaseZona = const Duration(hours: -5),
}) {
  final mesActual = _mesDe(ahora, desfaseZona);
  final limiteMasPedidos = ahora.toUtc().subtract(
    const Duration(days: diasMasPedidos),
  );

  var esteMes = 0;
  var anterior = 0;
  final unidades = <String, int>{};
  for (final pedido in pedidos) {
    if (pedido.estado == EstadoPedido.cancelado) continue;

    final mes = _mesDe(pedido.creadoEn, desfaseZona);
    if (mes == mesActual) {
      esteMes += pedido.totalCentimos;
    } else if (mes == mesActual - 1) {
      anterior += pedido.totalCentimos;
    }

    if (!pedido.creadoEn.toUtc().isBefore(limiteMasPedidos)) {
      for (final item in pedido.items) {
        unidades.update(
          item.productoId,
          (u) => u + item.cantidad * item.factor,
          ifAbsent: () => item.cantidad * item.factor,
        );
      }
    }
  }

  final masPedidos = unidades.keys.toList()
    ..sort((a, b) {
      final porUnidades = unidades[b]!.compareTo(unidades[a]!);
      return porUnidades != 0 ? porUnidades : a.compareTo(b);
    });

  return ResumenCompras(
    ultimoPedido: ultimoPedido,
    compradoEsteMesCentimos: esteMes,
    compradoMesAnteriorCentimos: anterior,
    variacionPorcentaje: anterior == 0
        ? null
        : _redondearDivision((esteMes - anterior) * 100, anterior),
    productosMasPedidos: masPedidos.take(maxProductosMasPedidos).toList(),
    mesAnterior: (mesActual - 1) % 12 + 1,
  );
}

/// Los productos de [ids] que siguen en [productos], en el orden de [ids].
List<ProductoEnCatalogo> productosEnOrden(
  List<ProductoEnCatalogo> productos,
  List<String> ids,
) {
  final porId = {for (final p in productos) p.producto.id: p};
  return [for (final id in ids) ?porId[id]];
}

/// Texto del estado de un pedido para la bodega.
String etiquetaEstado(EstadoPedido estado) => switch (estado) {
  EstadoPedido.recibido => 'Recibido',
  EstadoPedido.confirmado => 'Confirmado',
  EstadoPedido.enCamino => 'En camino',
  EstadoPedido.listoRecojo => 'Listo para recoger',
  EstadoPedido.entregado => 'Entregado',
  EstadoPedido.cancelado => 'Cancelado',
};

/// Nombre del [mes] (1 = enero) en español, en minúsculas.
String nombreMes(int mes) => _meses[mes - 1];

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Mes de [instante] en la zona [desfase], como número correlativo
/// (año × 12 + mes − 1): el anterior de enero es diciembre del año previo.
int _mesDe(DateTime instante, Duration desfase) {
  final local = instante.toUtc().add(desfase);
  return local.year * 12 + local.month - 1;
}

/// [dividendo] ÷ [divisor] (positivo) redondeado al entero más cercano; la
/// mitad se aleja del cero. Sin `double`.
int _redondearDivision(int dividendo, int divisor) {
  final mitad = dividendo >= 0 ? divisor : -divisor;
  return (2 * dividendo + mitad) ~/ (2 * divisor);
}
