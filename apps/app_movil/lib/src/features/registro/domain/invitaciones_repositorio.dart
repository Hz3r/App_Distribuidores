import 'invitacion_previa.dart';

/// Resultado de consultar un código antes de tener cuenta.
sealed class ResultadoConsulta {
  const ResultadoConsulta();
}

/// El código se puede canjear.
final class CodigoValido extends ResultadoConsulta {
  const CodigoValido(this.invitacion);

  final InvitacionPrevia invitacion;
}

/// El código no existe, ya se usó, se revocó, venció o su bodega está
/// inactiva. La BD no distingue entre esos casos.
final class CodigoNoValido extends ResultadoConsulta {
  const CodigoNoValido();
}

/// Demasiadas consultas fallidas desde esta red (`P0005`).
final class ConsultaFrenada extends ResultadoConsulta {
  const ConsultaFrenada();
}

/// No se pudo hacer la consulta (red u otro fallo).
final class ConsultaSinConexion extends ResultadoConsulta {
  const ConsultaSinConexion();
}

/// Acceso a las invitaciones. Las decisiones (cuándo consultar, qué mostrar)
/// están en `presentation/registro_providers.dart`, no aquí.
abstract interface class InvitacionesRepositorio {
  /// Consulta un código sin necesidad de sesión. No lanza: los fallos
  /// llegan como [ConsultaFrenada] o [ConsultaSinConexion].
  Future<ResultadoConsulta> consultar(String codigo);

  /// Canjea con la sesión actual. true si quedó vinculada.
  Future<bool> canjear(String codigo);
}
