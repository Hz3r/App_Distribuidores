import 'dart:math' as math;

/// Cuántas presentaciones completas se pueden vender: (físico − comprometido)
/// ÷ [factor], hacia abajo, nunca negativo (ver `docs/contrato.md`).
int disponiblePresentacion({
  required int stockFisico,
  required int stockComprometido,
  required int factor,
}) => math.max(0, (stockFisico - stockComprometido) ~/ factor);
