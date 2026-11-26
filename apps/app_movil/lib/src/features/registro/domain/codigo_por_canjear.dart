/// Código de invitación ya validado que se canjea en cuanto la persona
/// ingresa con su cuenta existente (ver `docs/contrato.md`, sección 7).
///
/// Lo pasa el registro a la pantalla de ingreso (por `extra` de go_router)
/// cuando el correo ya tiene cuenta. Nunca lleva la contraseña. Lógica pura:
/// sin Flutter ni Supabase.
final class CodigoPorCanjear {
  const CodigoPorCanjear({required this.codigo, required this.distribuidorId});

  final String codigo;

  /// Distribuidor de la invitación, tal como lo devolvió
  /// `consultar_invitacion`: sirve para saber si, tras el canje, la persona
  /// quedó con acceso ahí.
  final String distribuidorId;
}
