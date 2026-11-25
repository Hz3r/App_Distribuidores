import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/autenticacion.dart';

/// [Autenticacion] sobre Supabase Auth (correo y contraseña).
class AutenticacionSupabase implements Autenticacion {
  AutenticacionSupabase(this._cliente);

  final SupabaseClient _cliente;

  @override
  String? get correoActual => _cliente.auth.currentUser?.email;

  @override
  Future<ResultadoIngreso> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _cliente.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      return ResultadoIngreso.ok;
    } on AuthException catch (e, st) {
      if (e.code == 'invalid_credentials') {
        return ResultadoIngreso.credencialesInvalidas;
      }
      _registrar(e, st);
      return ResultadoIngreso.fallo;
    } catch (e, st) {
      _registrar(e, st);
      return ResultadoIngreso.fallo;
    }
  }

  @override
  Future<void> cerrarSesion() => _cliente.auth.signOut();

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'No se pudo iniciar sesión.',
      name: 'autenticacion',
      error: error,
      stackTrace: pila,
    );
  }
}
