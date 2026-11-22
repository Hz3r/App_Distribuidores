import 'package:freezed_annotation/freezed_annotation.dart';

import 'config_tema.dart';
import 'enums.dart';

part 'distribuidor.freezed.dart';
part 'distribuidor.g.dart';

/// Distribuidor (tenant), tabla `distribuidores`. Todo dato del negocio pertenece a uno.
@freezed
abstract class Distribuidor with _$Distribuidor {
  const factory Distribuidor({
    required String id,
    required String nombre,
    required String slug,
    String? rubro,
    String? documento,
    String? telefono,
    required EstadoDistribuidor estado,
    required String moneda,
    required String zonaHoraria,
    required ConfigTema configTema,
    required DateTime creadoEn,
  }) = _Distribuidor;

  factory Distribuidor.fromJson(Map<String, dynamic> json) =>
      _$DistribuidorFromJson(json);
}
