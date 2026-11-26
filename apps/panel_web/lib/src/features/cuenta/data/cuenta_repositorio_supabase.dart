import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cuenta_repositorio.dart';

/// [CuentaRepositorio] sobre Supabase: el perfil en `perfiles` y la
/// contraseña en Supabase Auth.
class CuentaRepositorioSupabase implements CuentaRepositorio {
  CuentaRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  User get _usuario {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) {
      throw const ErrorCuenta(MotivoErrorCuenta.sinPermiso);
    }
    return usuario;
  }

  @override
  Future<Perfil> leerPerfil() {
    return _intentar(() async {
      final fila = await _cliente
          .from('perfiles')
          .select()
          .eq('id', _usuario.id)
          .single();
      return Perfil.fromJson(fila);
    });
  }

  @override
  Future<Perfil> actualizarNombre(String nombre) {
    return _intentar(() async {
      // Un `update` que la política no permite no cambia ninguna fila.
      final filas = await _cliente
          .from('perfiles')
          .update({'nombre': nombre.trim()})
          .eq('id', _usuario.id)
          .select();
      if (filas.isEmpty) {
        throw const ErrorCuenta(MotivoErrorCuenta.sinPermiso);
      }
      return Perfil.fromJson(filas.first);
    });
  }

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) {
    return _intentar(() async {
      final correo = _usuario.email;
      if (correo == null) {
        throw const ErrorCuenta(MotivoErrorCuenta.sinPermiso);
      }
      // Verifica la contraseña actual volviendo a ingresar con la misma
      // cuenta: la sesión sigue siendo de la misma persona, así que el
      // panel no se recarga.
      try {
        await _cliente.auth.signInWithPassword(email: correo, password: actual);
      } on AuthException catch (e) {
        if (e.code == 'invalid_credentials') {
          throw const ErrorCuenta(MotivoErrorCuenta.contrasenaIncorrecta);
        }
        rethrow;
      }
      await _cliente.auth.updateUser(UserAttributes(password: nueva));
    });
  }

  Future<T> _intentar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on ErrorCuenta {
      rethrow;
    } on AuthException catch (e, st) {
      _registrar(e, st);
      throw ErrorCuenta(switch (e.code) {
        'weak_password' => MotivoErrorCuenta.contrasenaDebil,
        'same_password' => MotivoErrorCuenta.mismaContrasena,
        _ => MotivoErrorCuenta.desconocido,
      });
    } on PostgrestException catch (e, st) {
      _registrar(e, st);
      throw ErrorCuenta(
        e.code == '42501'
            ? MotivoErrorCuenta.sinPermiso
            : MotivoErrorCuenta.desconocido,
      );
    } catch (e, st) {
      _registrar(e, st);
      throw const ErrorCuenta(MotivoErrorCuenta.desconocido);
    }
  }

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'Falló una operación de la cuenta.',
      name: 'cuenta',
      error: error,
      stackTrace: pila,
    );
  }
}
