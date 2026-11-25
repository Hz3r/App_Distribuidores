import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/clientes_repositorio.dart';

/// [ClientesRepositorio] sobre Supabase. Los clientes se escriben con
/// `insert`/`update`; las invitaciones, solo con las funciones del contrato.
class ClientesRepositorioSupabase implements ClientesRepositorio {
  ClientesRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  // `order` de supabase-dart ordena de mayor a menor si no se le dice.

  @override
  Future<List<ClienteNegocio>> listarClientes(String distribuidorId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('clientes_negocio')
          .select()
          .eq('distribuidor_id', distribuidorId)
          .order('nombre_negocio', ascending: true);
      return filas.map(ClienteNegocio.fromJson).toList();
    });
  }

  @override
  Future<List<PersonaCliente>> listarPersonas(String distribuidorId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('membresias')
          .select(
            'id, cliente_negocio_id, estado, perfil:perfiles(nombre, telefono)',
          )
          .eq('distribuidor_id', distribuidorId)
          .eq('rol', 'cliente');
      return [
        for (final fila in filas)
          if (fila['cliente_negocio_id'] case final String clienteId)
            PersonaCliente(
              membresiaId: fila['id'] as String,
              clienteNegocioId: clienteId,
              estado: fila['estado'] == 'activa'
                  ? EstadoMembresia.activa
                  : EstadoMembresia.suspendida,
              nombre: _texto(fila['perfil'], 'nombre'),
              telefono: _texto(fila['perfil'], 'telefono'),
            ),
      ];
    });
  }

  @override
  Future<List<Invitacion>> listarInvitaciones(String distribuidorId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('invitaciones')
          .select()
          .eq('distribuidor_id', distribuidorId)
          .eq('rol', 'cliente')
          .order('creado_en', ascending: false);
      return filas.map(Invitacion.fromJson).toList();
    });
  }

  @override
  Future<String> crearCliente(String distribuidorId, DatosCliente datos) {
    return _intentar(() async {
      final fila = await _cliente
          .from('clientes_negocio')
          .insert({'distribuidor_id': distribuidorId, ..._columnas(datos)})
          .select('id')
          .single();
      return fila['id'] as String;
    });
  }

  @override
  Future<void> actualizarCliente(String clienteId, DatosCliente datos) {
    return _intentar(() async {
      // Un `update` que la política no permite no da error: no cambia
      // ninguna fila. Por eso se pide el id de vuelta.
      final filas = await _cliente
          .from('clientes_negocio')
          .update(_columnas(datos))
          .eq('id', clienteId)
          .select('id');
      if (filas.isEmpty) {
        throw const ErrorClientes(MotivoErrorClientes.sinPermiso);
      }
    });
  }

  @override
  Future<Invitacion> crearInvitacion({
    required String distribuidorId,
    required String clienteId,
    required int diasVigencia,
  }) {
    return _intentar(() async {
      final fila = await _cliente.rpc<Map<String, dynamic>>(
        'crear_invitacion',
        params: {
          'p_distribuidor_id': distribuidorId,
          'p_rol': 'cliente',
          'p_cliente_negocio_id': clienteId,
          'p_dias_vigencia': diasVigencia,
        },
      );
      return Invitacion.fromJson(fila);
    });
  }

  @override
  Future<void> revocarInvitacion(String invitacionId) {
    return _intentar(() async {
      await _cliente.rpc<void>(
        'revocar_invitacion',
        params: {'p_invitacion_id': invitacionId},
      );
    });
  }

  /// Columnas a escribir. Las de crédito solo van si [DatosCliente.credito]
  /// viene: un vendedor que las mande recibe `42501` del trigger.
  Map<String, Object?> _columnas(DatosCliente datos) {
    final credito = datos.credito;
    return {
      'nombre_negocio': datos.nombreNegocio,
      'documento': _oNulo(datos.documento),
      'telefono': _oNulo(datos.telefono),
      'direccion': _oNulo(datos.direccion),
      'referencia': _oNulo(datos.referencia),
      'activo': datos.activo,
      if (credito != null) ...{
        'credito_habilitado': credito.habilitado,
        'limite_credito_centimos': credito.limiteCentimos,
        'plazo_credito_dias': credito.plazoDias,
      },
    };
  }

  String? _oNulo(String? texto) {
    final limpio = texto?.trim() ?? '';
    return limpio.isEmpty ? null : limpio;
  }

  String? _texto(Object? objeto, String clave) {
    if (objeto is! Map) return null;
    final valor = objeto[clave];
    return valor is String && valor.trim().isNotEmpty ? valor : null;
  }

  Future<T> _intentar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on ErrorClientes {
      rethrow;
    } on PostgrestException catch (e, st) {
      final motivo = switch (e.code) {
        '42501' => MotivoErrorClientes.sinPermiso,
        'P0006' => MotivoErrorClientes.invitacionUsada,
        '22023' || '23514' || '23502' => MotivoErrorClientes.datoInvalido,
        _ => MotivoErrorClientes.desconocido,
      };
      _registrar(e, st);
      throw ErrorClientes(motivo);
    } catch (e, st) {
      _registrar(e, st);
      throw const ErrorClientes(MotivoErrorClientes.desconocido);
    }
  }

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'Falló una operación de clientes.',
      name: 'clientes',
      error: error,
      stackTrace: pila,
    );
  }
}
