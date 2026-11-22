import 'package:freezed_annotation/freezed_annotation.dart';

part 'precio_lista.freezed.dart';
part 'precio_lista.g.dart';

/// Precio de una presentación dentro de una lista de precios, tabla `precios_lista`.
@freezed
abstract class PrecioLista with _$PrecioLista {
  const factory PrecioLista({
    required String id,
    required String distribuidorId,
    required String listaPreciosId,
    required String presentacionId,
    required int precioCentimos,
    required DateTime creadoEn,
  }) = _PrecioLista;

  factory PrecioLista.fromJson(Map<String, dynamic> json) =>
      _$PrecioListaFromJson(json);
}
