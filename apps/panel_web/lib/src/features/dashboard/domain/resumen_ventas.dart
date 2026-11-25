import 'dart:math';

import 'package:core/core.dart';

/// Ventas de un día (hora del dispositivo).
class VentaDia {
  const VentaDia({
    required this.dia,
    required this.centimos,
    required this.pedidos,
  });

  /// Medianoche de ese día.
  final DateTime dia;
  final int centimos;
  final int pedidos;
}

/// Ventas a un cliente en el mes.
class VentaCliente {
  const VentaCliente({
    required this.clienteId,
    required this.centimos,
    required this.pedidos,
  });

  final String clienteId;
  final int centimos;
  final int pedidos;
}

/// Indicadores del Dashboard. Una **venta** es un pedido no cancelado, y
/// cuenta en la fecha en que se creó (hora del dispositivo).
class ResumenVentas {
  const ResumenVentas({
    required this.ventasMesCentimos,
    required this.pedidosMes,
    required this.ventasMesAnteriorCentimos,
    required this.clientesQueCompraron,
    required this.porConfirmar,
    required this.llegaronHoy,
    required this.ultimosDias,
    required this.topClientes,
  });

  /// Vendido desde el día 1 del mes hasta ahora.
  final int ventasMesCentimos;
  final int pedidosMes;

  /// Vendido el mes anterior hasta el mismo día y hora (para comparar
  /// periodos iguales, no un mes a medias contra uno completo).
  final int ventasMesAnteriorCentimos;

  /// Clientes distintos con al menos una venta este mes.
  final int clientesQueCompraron;

  /// Pedidos recibidos que esperan confirmación.
  final int porConfirmar;

  /// De esos, los que llegaron hoy.
  final int llegaronHoy;

  /// Los últimos 7 días, del más antiguo a hoy.
  final List<VentaDia> ultimosDias;

  /// Hasta 5 clientes, del que más compró al que menos.
  final List<VentaCliente> topClientes;

  int get ventasUltimosDiasCentimos =>
      ultimosDias.fold(0, (suma, d) => suma + d.centimos);
}

/// Desde cuándo hay que leer pedidos para armar el resumen en [ahora]: el
/// día 1 del mes anterior.
DateTime inicioDelResumen(DateTime ahora) {
  final local = ahora.toLocal();
  return DateTime(local.year, local.month - 1);
}

/// Arma los indicadores a partir de los pedidos del periodo.
ResumenVentas resumirVentas(List<Pedido> pedidos, DateTime momento) {
  // Todo en la hora del dispositivo, igual que las fechas de los pedidos.
  final ahora = momento.toLocal();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final inicioMes = DateTime(ahora.year, ahora.month);
  final inicioMesAnterior = inicioDelResumen(ahora);
  // Mismo día y hora del mes anterior; si ese mes es más corto (31 → 30),
  // su último día.
  final ultimoDiaAnterior = DateTime(ahora.year, ahora.month, 0).day;
  final corteMesAnterior = DateTime(
    inicioMesAnterior.year,
    inicioMesAnterior.month,
    min(ahora.day, ultimoDiaAnterior),
    ahora.hour,
    ahora.minute,
    ahora.second,
  );
  final inicioSemana = hoy.subtract(const Duration(days: 6));

  var ventasMes = 0;
  var pedidosMes = 0;
  var ventasMesAnterior = 0;
  var porConfirmar = 0;
  var llegaronHoy = 0;
  final porDia = <DateTime, (int, int)>{};
  final porCliente = <String, (int, int)>{};

  for (final pedido in pedidos) {
    final creado = pedido.creadoEn.toLocal();
    if (pedido.estado == EstadoPedido.recibido) {
      porConfirmar++;
      if (!creado.isBefore(hoy)) llegaronHoy++;
    }
    if (pedido.estado == EstadoPedido.cancelado) continue;

    final total = pedido.totalCentimos;
    if (!creado.isBefore(inicioMes)) {
      ventasMes += total;
      pedidosMes++;
      final (suma, cuenta) = porCliente[pedido.clienteId] ?? (0, 0);
      porCliente[pedido.clienteId] = (suma + total, cuenta + 1);
    } else if (!creado.isBefore(inicioMesAnterior) &&
        !creado.isAfter(corteMesAnterior)) {
      ventasMesAnterior += total;
    }
    if (!creado.isBefore(inicioSemana)) {
      final dia = DateTime(creado.year, creado.month, creado.day);
      final (suma, cuenta) = porDia[dia] ?? (0, 0);
      porDia[dia] = (suma + total, cuenta + 1);
    }
  }

  final top =
      [
        for (final MapEntry(:key, :value) in porCliente.entries)
          VentaCliente(clienteId: key, centimos: value.$1, pedidos: value.$2),
      ]..sort((a, b) {
        final porMonto = b.centimos.compareTo(a.centimos);
        return porMonto != 0 ? porMonto : a.clienteId.compareTo(b.clienteId);
      });

  return ResumenVentas(
    ventasMesCentimos: ventasMes,
    pedidosMes: pedidosMes,
    ventasMesAnteriorCentimos: ventasMesAnterior,
    clientesQueCompraron: porCliente.length,
    porConfirmar: porConfirmar,
    llegaronHoy: llegaronHoy,
    ultimosDias: [
      for (var i = 0; i < 7; i++)
        () {
          // Con `DateTime(año, mes, día + i)` y no sumando 24 h: así un
          // cambio de hora no descuadra los días.
          final dia = DateTime(
            inicioSemana.year,
            inicioSemana.month,
            inicioSemana.day + i,
          );
          final (suma, cuenta) = porDia[dia] ?? (0, 0);
          return VentaDia(dia: dia, centimos: suma, pedidos: cuenta);
        }(),
    ],
    topClientes: top.take(5).toList(),
  );
}

/// Cambio porcentual de [anterior] a [actual], redondeado. Null si no hay
/// con qué comparar.
int? variacionPorcentual(int actual, int anterior) {
  if (anterior <= 0) return null;
  return ((actual - anterior) * 100 / anterior).round();
}
