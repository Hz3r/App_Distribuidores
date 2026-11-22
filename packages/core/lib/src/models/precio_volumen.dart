import 'package:freezed_annotation/freezed_annotation.dart';

part 'precio_volumen.freezed.dart';
part 'precio_volumen.g.dart';

/// Precio por volumen, tabla `precios_volumen`: a partir de [cantidadMinima]
/// unidades de la presentación aplica [precioCentimos].
@freezed
abstract class PrecioVolumen with _$PrecioVolumen {
  const factory PrecioVolumen({
    required String id,
    required String distribuidorId,
    required String presentacionId,
    required int cantidadMinima,
    required int precioCentimos,
    required DateTime creadoEn,
  }) = _PrecioVolumen;

  factory PrecioVolumen.fromJson(Map<String, dynamic> json) =>
      _$PrecioVolumenFromJson(json);
}
