import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cuentas_repositorio.dart';
import '../domain/datos_registro.dart';
import '../domain/registro_pendiente.dart';

/// [CuentasRepositorio] sobre Supabase Auth. Delgado a propósito: llama a
/// Auth y a la BD y traduce sus respuestas.
///
/// La contraseña solo va a `signUp` y `signInWithPassword`: nunca a los
/// registros (`log`) ni a `user_metadata`.
class CuentasRepositorioSupabase implements CuentasRepositorio {
  CuentasRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  /// Códigos de error de Supabase Auth (`AuthException.code`).
  static const _yaExiste = 'user_already_exists';
  static const _credencialesIncorrectas = 'invalid_credentials';
  static const _correoSinConfirmar = 'email_not_confirmed';

  @override
  Future<ResultadoCrearCuenta> crearCuenta(
    DatosRegistro datos,
    RegistroPendiente pendiente,
  ) async {
    try {
      final respuesta = await _cliente.auth.signUp(
        email: datos.correo,
        password: datos.contrasena,
        // `nombre` lo copia la BD a `perfiles.nombre` al crear la cuenta.
        data: {'nombre': datos.nombreEncargado, ...pendiente.toMetadata()},
      );
      if (respuesta.session != null) return ResultadoCrearCuenta.conSesion;
      final usuario = respuesta.user;
      if (usuario == null) {
        _registrar('signUp no devolvió sesión ni usuario.', null, null);
        return ResultadoCrearCuenta.error;
      }
      // Con confirmación de correo, Supabase no revela si el correo ya
      // existe: devuelve un usuario sin identidades en vez de un error.
      if (usuario.identities?.isEmpty ?? false) {
        return ResultadoCrearCuenta.correoYaRegistrado;
      }
      return ResultadoCrearCuenta.requiereConfirmarCorreo;
    } on AuthException catch (e, st) {
      // Sin confirmación de correo, un correo repetido sí da error.
      if (e.code == _yaExiste) return ResultadoCrearCuenta.correoYaRegistrado;
      _registrar('No se pudo crear la cuenta.', e, st);
      return _esSinConexion(e)
          ? ResultadoCrearCuenta.sinConexion
          : ResultadoCrearCuenta.error;
    } catch (e, st) {
      _registrar('No se pudo crear la cuenta.', e, st);
      return _esSinConexion(e)
          ? ResultadoCrearCuenta.sinConexion
          : ResultadoCrearCuenta.error;
    }
  }

  @override
  Future<ResultadoIngreso> ingresar(String correo, String contrasena) async {
    try {
      await _cliente.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      return ResultadoIngreso.ok;
    } on AuthException catch (e, st) {
      if (e.code == _credencialesIncorrectas) {
        return ResultadoIngreso.credencialesIncorrectas;
      }
      if (e.code == _correoSinConfirmar) {
        return ResultadoIngreso.correoSinConfirmar;
      }
      _registrar('No se pudo ingresar.', e, st);
      return _esSinConexion(e)
          ? ResultadoIngreso.sinConexion
          : ResultadoIngreso.error;
    } catch (e, st) {
      _registrar('No se pudo ingresar.', e, st);
      return _esSinConexion(e)
          ? ResultadoIngreso.sinConexion
          : ResultadoIngreso.error;
    }
  }

  @override
  RegistroPendiente? pendienteActual() =>
      RegistroPendiente.desdeMetadata(_cliente.auth.currentUser?.userMetadata);

  @override
  Future<void> limpiarPendiente() async {
    // Emite `userUpdated` con la misma sesión: el control de acceso lo
    // ignora y no recarga.
    await _cliente.auth.updateUser(
      UserAttributes(data: {RegistroPendiente.clave: null}),
    );
  }

  @override
  Future<void> completarDatosNegocio(
    String distribuidorId,
    RegistroPendiente pendiente,
  ) async {
    await _cliente.rpc<void>(
      'completar_datos_negocio',
      params: {
        'p_distribuidor_id': distribuidorId,
        'p_documento': pendiente.documento,
        'p_direccion': pendiente.direccion,
        'p_referencia': pendiente.referencia,
        'p_telefono': pendiente.telefono,
      },
    );
  }

  /// gotrue envuelve los fallos de red en [AuthRetryableFetchException] sin
  /// código HTTP; con código HTTP es un error del servidor (5xx), no de la
  /// red.
  static bool _esSinConexion(Object error) =>
      (error is AuthRetryableFetchException && error.statusCode == null) ||
      error is TimeoutException;

  void _registrar(String mensaje, Object? error, StackTrace? st) {
    developer.log(mensaje, name: 'cuentas', error: error, stackTrace: st);
  }
}
