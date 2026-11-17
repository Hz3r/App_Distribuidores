import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'presentacion.freezed.dart';
part 'presentacion.g.dart';

/// Presentación vendible de un producto (botella, six pack, caja).
/// Precio en céntimos (enteros) para evitar errores de punto flotante.
@freezed
abstract class Presentacion with _$Presentacion {
  const factory Presentacion({
    required String id,
    required String productoId,
    required TipoPresentacion tipo,
    required String nombre,
    required int precioBaseCentimos,
    required int stock,
    @Default(1) int unidadesPorPresentacion,
  }) = _Presentacion;

  factory Presentacion.fromJson(Map<String, dynamic> json) =>
      _$PresentacionFromJson(json);
}
