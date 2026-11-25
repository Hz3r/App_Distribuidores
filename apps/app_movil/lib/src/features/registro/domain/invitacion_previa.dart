import 'package:core/core.dart';

/// Lo que `consultar_invitacion` deja ver de una invitación antes de tener
/// cuenta. Lógica pura: sin Flutter ni Supabase.
final class InvitacionPrevia {
  const InvitacionPrevia({
    required this.distribuidorId,
    required this.distribuidorNombre,
    required this.rol,
    this.negocio,
  });

  /// Lee el JSON de `consultar_invitacion` (ver `docs/contrato.md`). Lanza
  /// [FormatException] si el rol no es uno conocido.
  factory InvitacionPrevia.desdeJson(Map<String, dynamic> json) {
    final negocio = json['negocio'];
    return InvitacionPrevia(
      distribuidorId: json['distribuidor_id'] as String,
      distribuidorNombre: json['distribuidor_nombre'] as String,
      rol: _rolDesde(json['rol']),
      negocio: negocio == null
          ? null
          : NegocioPrevio.desdeJson(Map<String, dynamic>.from(negocio as Map)),
    );
  }

  final String distribuidorId;

  /// Nombre visible del distribuidor (el de su marca, si lo configuró).
  final String distribuidorNombre;

  final RolMembresia rol;

  /// Datos de la bodega que cargó el distribuidor. Solo en invitaciones de
  /// rol cliente; `null` en las demás.
  final NegocioPrevio? negocio;
}

/// Datos de la bodega invitada, tal como los cargó el distribuidor.
final class NegocioPrevio {
  const NegocioPrevio({
    required this.nombreNegocio,
    this.documento,
    this.direccion,
    this.referencia,
    this.telefono,
  });

  factory NegocioPrevio.desdeJson(Map<String, dynamic> json) => NegocioPrevio(
    nombreNegocio: json['nombre_negocio'] as String,
    documento: json['documento'] as String?,
    direccion: json['direccion'] as String?,
    referencia: json['referencia'] as String?,
    telefono: json['telefono'] as String?,
  );

  final String nombreNegocio;
  final String? documento;
  final String? direccion;
  final String? referencia;
  final String? telefono;
}

/// Lo que la pantalla de código le pasa al registro: el código ya validado
/// y lo que se vio de la invitación.
final class DatosRegistro {
  const DatosRegistro({required this.codigo, required this.invitacion});

  final String codigo;
  final InvitacionPrevia invitacion;
}

/// Los valores de `rol_membresia` en la BD coinciden con los nombres de
/// [RolMembresia].
RolMembresia _rolDesde(Object? valor) {
  for (final rol in RolMembresia.values) {
    if (rol.name == valor) return rol;
  }
  throw FormatException('Rol de invitación desconocido: $valor');
}
