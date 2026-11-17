import 'package:freezed_annotation/freezed_annotation.dart';

import 'config_tema.dart';

part 'distribuidor.freezed.dart';
part 'distribuidor.g.dart';

/// Distribuidor (tenant). Todo dato del negocio pertenece a uno.
@freezed
abstract class Distribuidor with _$Distribuidor {
  const factory Distribuidor({
    required String id,
    required String nombre,
    ConfigTema? configTema,
  }) = _Distribuidor;

  factory Distribuidor.fromJson(Map<String, dynamic> json) =>
      _$DistribuidorFromJson(json);
}
