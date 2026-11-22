import 'package:freezed_annotation/freezed_annotation.dart';

import 'precio_volumen.dart';
import 'producto.dart';

part 'presentacion.freezed.dart';
part 'presentacion.g.dart';

/// Presentación vendible de un producto (botella, six pack, caja), tabla
/// `presentaciones`. [factor] es cuántas unidades base contiene.
/// Precio en céntimos (enteros) para evitar errores de punto flotante.
///
/// [preciosVolumen] solo viene llena si la consulta la embebe:
/// `select('*, precios_volumen(*)')`.
@freezed
abstract class Presentacion with _$Presentacion {
  const Presentacion._();

  const factory Presentacion({
    required String id,
    required String distribuidorId,
    required String productoId,
    required String nombre,
    required int factor,
    required int precioBaseCentimos,
    required int orden,
    required bool activo,
    required DateTime creadoEn,
    @Default(<PrecioVolumen>[]) List<PrecioVolumen> preciosVolumen,
  }) = _Presentacion;

  factory Presentacion.fromJson(Map<String, dynamic> json) =>
      _$PresentacionFromJson(json);

  /// Cuántas presentaciones completas alcanzan con el stock disponible de [producto].
  int disponiblePara(Producto producto) => producto.stockDisponible ~/ factor;
}
