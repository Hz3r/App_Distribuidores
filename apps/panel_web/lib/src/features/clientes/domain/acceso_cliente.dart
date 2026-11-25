import 'package:core/core.dart';

import '../../../shared/formato.dart';
import 'clientes_repositorio.dart';

/// En qué está una invitación.
enum EstadoInvitacion {
  /// Se puede usar todavía.
  vigente,

  /// Alguien ya la canjeó.
  usada,

  /// Pasó su fecha sin usarse.
  vencida,

  /// El distribuidor la anuló.
  revocada,
}

/// Estado de [invitacion] en el momento [ahora]. Una invitación usada sigue
/// "usada" aunque después se haya vencido; revocada manda sobre vencida.
EstadoInvitacion estadoDe(Invitacion invitacion, DateTime ahora) {
  if (invitacion.usadaEn != null) return EstadoInvitacion.usada;
  if (invitacion.revocadaEn != null) return EstadoInvitacion.revocada;
  if (!invitacion.venceEn.isAfter(ahora)) return EstadoInvitacion.vencida;
  return EstadoInvitacion.vigente;
}

/// Si un cliente ya puede pedir desde la app.
enum AccesoCliente {
  // El orden es el de los filtros de la pantalla Clientes.

  /// Al menos una persona entra a la app a su nombre.
  conAcceso,

  /// Nadie entró todavía, pero tiene un código vigente.
  invitado,

  /// Nadie entra y no tiene código: falta invitarlo.
  sinAcceso,

  /// Desactivado por el distribuidor: no puede pedir ni entrar.
  inactivo,
}

/// Acceso de [cliente] según sus personas y sus invitaciones.
AccesoCliente accesoDe(
  ClienteNegocio cliente, {
  required List<PersonaCliente> personas,
  required List<Invitacion> invitaciones,
  required DateTime ahora,
}) {
  if (!cliente.activo) return AccesoCliente.inactivo;
  final entraAlguien = personas.any(
    (p) =>
        p.clienteNegocioId == cliente.id && p.estado == EstadoMembresia.activa,
  );
  if (entraAlguien) return AccesoCliente.conAcceso;
  final tieneCodigo = invitaciones.any(
    (i) =>
        i.clienteNegocioId == cliente.id &&
        estadoDe(i, ahora) == EstadoInvitacion.vigente,
  );
  return tieneCodigo ? AccesoCliente.invitado : AccesoCliente.sinAcceso;
}

/// Clientes que coinciden con la búsqueda: nombre, documento, teléfono o
/// dirección, sin importar tildes ni mayúsculas. Conserva el orden.
List<ClienteNegocio> filtrarClientes(
  List<ClienteNegocio> clientes,
  String busqueda,
) {
  final buscado = normalizarBusqueda(busqueda);
  if (buscado.isEmpty) return clientes;
  return [
    for (final c in clientes)
      if ([c.nombreNegocio, c.documento, c.telefono, c.direccion].any(
        (campo) => campo != null && normalizarBusqueda(campo).contains(buscado),
      ))
        c,
  ];
}
