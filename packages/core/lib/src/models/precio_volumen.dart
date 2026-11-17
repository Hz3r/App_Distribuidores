import 'package:freezed_annotation/freezed_annotation.dart';

part 'precio_volumen.freezed.dart';
part 'precio_volumen.g.dart';

/// Precio por volumen: a partir de [cantidadMinima] unidades aplica [precioCentimos].
@freezed
abstract class PrecioVolumen with _$PrecioVolumen {
  const factory PrecioVolumen({
    required String id,
    required String presentacionId,
    required int cantidadMinima,
    required int precioCentimos,
  }) = _PrecioVolumen;

  factory PrecioVolumen.fromJson(Map<String, dynamic> json) =>
      _$PrecioVolumenFromJson(json);
}
