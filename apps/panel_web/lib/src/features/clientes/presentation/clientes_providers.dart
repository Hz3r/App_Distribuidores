import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/control_acceso.dart';
import '../data/clientes_repositorio_supabase.dart';
import '../domain/clientes_repositorio.dart';

part 'clientes_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.
@Riverpod(keepAlive: true)
ClientesRepositorio clientesRepositorio(Ref ref) =>
    ClientesRepositorioSupabase(supabase);

/// Hora actual, para saber si una invitación venció. Las pruebas la fijan.
@Riverpod(keepAlive: true)
DateTime Function() reloj(Ref ref) => DateTime.now;

/// Clientes del distribuidor activo.
@riverpod
Future<List<ClienteNegocio>> clientes(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(clientesRepositorioProvider)
      .listarClientes(membresia.distribuidorId);
}

/// Personas que entran a la app a nombre de los clientes.
@riverpod
Future<List<PersonaCliente>> personasCliente(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(clientesRepositorioProvider)
      .listarPersonas(membresia.distribuidorId);
}

/// Invitaciones a clientes del distribuidor activo. Las comparten Clientes e
/// Invitaciones.
@riverpod
Future<List<Invitacion>> invitaciones(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(clientesRepositorioProvider)
      .listarInvitaciones(membresia.distribuidorId);
}

/// Escrituras de clientes e invitaciones. Cada una vuelve a leer lo que
/// cambió. Lanzan [ErrorClientes]; la pantalla lo convierte en mensaje con
/// [mensajeDeClientes].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.
@Riverpod(keepAlive: true)
AccionesClientes accionesClientes(Ref ref) => AccionesClientes(ref);

class AccionesClientes {
  AccionesClientes(this._ref);

  final Ref _ref;

  ClientesRepositorio get _repositorio =>
      _ref.read(clientesRepositorioProvider);

  String get _distribuidorId {
    final membresia = _ref.read(membresiaActivaProvider);
    if (membresia == null) {
      throw const ErrorClientes(MotivoErrorClientes.sinPermiso);
    }
    return membresia.distribuidorId;
  }

  /// Crea el cliente si [original] es null; si no, lo actualiza.
  Future<void> guardarCliente(
    DatosCliente datos, {
    ClienteNegocio? original,
  }) async {
    if (original == null) {
      await _repositorio.crearCliente(_distribuidorId, datos);
    } else {
      await _repositorio.actualizarCliente(original.id, datos);
    }
    _ref.invalidate(clientesProvider);
  }

  Future<Invitacion> invitar(
    String clienteId, {
    required int diasVigencia,
  }) async {
    final invitacion = await _repositorio.crearInvitacion(
      distribuidorId: _distribuidorId,
      clienteId: clienteId,
      diasVigencia: diasVigencia,
    );
    _ref.invalidate(invitacionesProvider);
    return invitacion;
  }

  Future<void> revocar(Invitacion invitacion) async {
    try {
      await _repositorio.revocarInvitacion(invitacion.id);
    } finally {
      // Si falló por "ya usada", la lista en pantalla estaba vieja.
      _ref.invalidate(invitacionesProvider);
      _ref.invalidate(personasClienteProvider);
    }
  }
}

/// Mensaje para la persona según por qué falló la operación.
String mensajeDeClientes(Object error) {
  final motivo = error is ErrorClientes
      ? error.motivo
      : MotivoErrorClientes.desconocido;
  return switch (motivo) {
    MotivoErrorClientes.sinPermiso =>
      'Tu cuenta no puede hacer este cambio. Pídeselo al administrador.',
    MotivoErrorClientes.invitacionUsada =>
      'Ese código ya fue usado, así que no se puede anular.',
    MotivoErrorClientes.datoInvalido =>
      'Hay un dato que no es válido. Revísalo e inténtalo de nuevo.',
    MotivoErrorClientes.desconocido =>
      'No pudimos guardar. Revisa tu conexión e inténtalo de nuevo.',
  };
}
