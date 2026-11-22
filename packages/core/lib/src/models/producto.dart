import 'package:freezed_annotation/freezed_annotation.dart';

import 'presentacion.dart';

part 'producto.freezed.dart';
part 'producto.g.dart';

/// Producto del catálogo, tabla `productos`. El stock se lleva en unidades
/// base ([unidadBase]); se vende por presentación.
///
/// [presentaciones] solo viene llena si la consulta la embebe:
/// `select('*, presentaciones(*, precios_volumen(*))')`.
@freezed
abstract class Producto with _$Producto {
  const Producto._();

  const factory Producto({
    required String id,
    required String distribuidorId,
    String? categoriaId,
    required String nombre,
    String? descripcion,
    String? marca,
    String? sku,
    String? imagenUrl,
    required String unidadBase,
    required int stockFisico,
    required int stockComprometido,
    required bool activo,
    required DateTime creadoEn,
    @Default(<Presentacion>[]) List<Presentacion> presentaciones,
  }) = _Producto;

  factory Producto.fromJson(Map<String, dynamic> json) =>
      _$ProductoFromJson(json);

  /// Unidades base que aún se pueden vender: físico menos comprometido.
  int get stockDisponible => stockFisico - stockComprometido;
}
