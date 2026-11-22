import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'movimiento_stock.freezed.dart';
part 'movimiento_stock.g.dart';

/// Movimiento del kardex de un producto, tabla `movimientos_stock`.
/// Los deltas están en unidades base.
@freezed
abstract class MovimientoStock with _$MovimientoStock {
  const factory MovimientoStock({
    required String id,
    required String distribuidorId,
    required String productoId,
    required TipoMovimientoStock tipo,
    required int deltaFisico,
    required int deltaComprometido,
    String? pedidoId,
    String? hechoPor,
    String? nota,
    required DateTime creadoEn,
  }) = _MovimientoStock;

  factory MovimientoStock.fromJson(Map<String, dynamic> json) =>
      _$MovimientoStockFromJson(json);
}
