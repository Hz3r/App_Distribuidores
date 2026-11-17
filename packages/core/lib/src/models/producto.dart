import 'package:freezed_annotation/freezed_annotation.dart';

part 'producto.freezed.dart';
part 'producto.g.dart';

/// Producto del catálogo. Sus ventas se hacen por presentación.
@freezed
abstract class Producto with _$Producto {
  const factory Producto({
    required String id,
    required String distribuidorId,
    required String categoriaId,
    required String nombre,
    String? descripcion,
    String? imagenUrl,
    @Default(true) bool activo,
  }) = _Producto;

  factory Producto.fromJson(Map<String, dynamic> json) =>
      _$ProductoFromJson(json);
}
