import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/invitacion_previa.dart';
import '../domain/invitaciones_repositorio.dart';

/// [InvitacionesRepositorio] sobre Supabase. Delgado a propósito: llama a
/// las funciones de la BD y traduce su respuesta; la lógica de la pantalla
/// vive en `presentation/registro_providers.dart`.
class InvitacionesRepositorioSupabase implements InvitacionesRepositorio {
  InvitacionesRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  /// SQLSTATE de "demasiados intentos" (ver `docs/contrato.md`).
  static const _codigoFrenada = 'P0005';

  @override
  Future<ResultadoConsulta> consultar(String codigo) async {
    try {
      // Se puede llamar sin sesión: la función está concedida a `anon`.
      final datos = await _cliente.rpc<dynamic>(
        'consultar_invitacion',
        params: {'p_codigo': codigo},
      );
      if (datos == null) return const CodigoNoValido();
      return CodigoValido(
        InvitacionPrevia.desdeJson(Map<String, dynamic>.from(datos as Map)),
      );
    } on PostgrestException catch (e, st) {
      if (e.code == _codigoFrenada) return const ConsultaFrenada();
      _registrar(e, st);
      return const ConsultaSinConexion();
    } catch (e, st) {
      // Red caída, tiempo agotado o una respuesta que no se pudo leer.
      _registrar(e, st);
      return const ConsultaSinConexion();
    }
  }

  @override
  Future<bool> canjear(String codigo) async {
    final membresiaId = await _cliente.rpc<dynamic>(
      'canjear_invitacion',
      params: {'p_codigo': codigo},
    );
    return membresiaId != null;
  }

  void _registrar(Object error, StackTrace st) {
    developer.log(
      'No se pudo consultar el código de invitación.',
      name: 'invitaciones',
      error: error,
      stackTrace: st,
    );
  }
}
