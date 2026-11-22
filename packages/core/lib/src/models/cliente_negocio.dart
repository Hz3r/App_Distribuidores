import 'package:freezed_annotation/freezed_annotation.dart';

part 'cliente_negocio.freezed.dart';
part 'cliente_negocio.g.dart';

/// Bodega o licorería que compra al distribuidor, tabla `clientes_negocio`.
/// Montos de crédito en céntimos; límite y plazo son nulos si no tiene crédito.
@freezed
abstract class ClienteNegocio with _$ClienteNegocio {
  const factory ClienteNegocio({
    required String id,
    required String distribuidorId,
    required String nombreNegocio,
    String? documento,
    String? direccion,
    String? referencia,
    String? telefono,
    required bool activo,
    required DateTime creadoEn,
    String? listaPreciosId,
    required bool creditoHabilitado,
    int? limiteCreditoCentimos,
    int? plazoCreditoDias,
  }) = _ClienteNegocio;

  factory ClienteNegocio.fromJson(Map<String, dynamic> json) =>
      _$ClienteNegocioFromJson(json);
}
