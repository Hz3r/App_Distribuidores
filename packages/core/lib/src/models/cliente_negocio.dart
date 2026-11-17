import 'package:freezed_annotation/freezed_annotation.dart';

part 'cliente_negocio.freezed.dart';
part 'cliente_negocio.g.dart';

/// Bodega o licorería que compra al distribuidor.
@freezed
abstract class ClienteNegocio with _$ClienteNegocio {
  const factory ClienteNegocio({
    required String id,
    required String distribuidorId,
    required String nombreNegocio,
    String? usuarioId,
    String? direccion,
  }) = _ClienteNegocio;

  factory ClienteNegocio.fromJson(Map<String, dynamic> json) =>
      _$ClienteNegocioFromJson(json);
}
