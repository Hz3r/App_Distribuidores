import 'package:freezed_annotation/freezed_annotation.dart';

import 'cliente_negocio.dart';
import 'distribuidor.dart';
import 'enums.dart';

part 'membresia.freezed.dart';
part 'membresia.g.dart';

/// Acceso de un perfil a un distribuidor con un rol, tabla `membresias`.
///
/// Las relaciones [distribuidor] y [clienteNegocio] solo vienen llenas si la
/// consulta las embebe con este alias:
/// `select('*, distribuidor:distribuidores(*), cliente_negocio:clientes_negocio(*)')`.
@freezed
abstract class Membresia with _$Membresia {
  const Membresia._();

  const factory Membresia({
    required String id,
    required String perfilId,
    required String distribuidorId,
    required RolMembresia rol,
    required EstadoMembresia estado,
    String? clienteNegocioId,
    required DateTime creadoEn,
    Distribuidor? distribuidor,
    ClienteNegocio? clienteNegocio,
  }) = _Membresia;

  factory Membresia.fromJson(Map<String, dynamic> json) =>
      _$MembresiaFromJson(json);

  /// `true` si la membresía permite entrar (`estado = 'activa'`).
  bool get estaActiva => estado == EstadoMembresia.activa;
}
