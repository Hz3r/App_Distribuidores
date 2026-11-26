import 'invitacion_previa.dart';

/// Lo que la pantalla de código le pasa al registro (por `extra` de
/// go_router): el código ya validado y lo que se vio de la invitación.
final class ArgumentosRegistro {
  const ArgumentosRegistro({required this.codigo, required this.invitacion});

  final String codigo;
  final InvitacionPrevia invitacion;
}
