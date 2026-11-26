import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/configuracion_repositorio.dart';
import '../domain/plan_vigente.dart';
import '../domain/validaciones.dart';

/// Bucket público de imágenes del catálogo y la marca (contrato, módulo 2).
const _bucket = 'catalogo';

/// [ConfiguracionRepositorio] sobre Supabase: `update` directo sobre las
/// columnas que el admin puede editar y Storage para el logo.
class ConfiguracionRepositorioSupabase implements ConfiguracionRepositorio {
  ConfiguracionRepositorioSupabase(this._cliente, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final SupabaseClient _cliente;
  final DateTime Function() _reloj;

  @override
  Future<Distribuidor> actualizarNegocio(
    String distribuidorId,
    DatosNegocio datos,
  ) {
    final telefono = datos.telefono?.trim() ?? '';
    return _actualizar(distribuidorId, {
      'nombre': datos.nombre.trim(),
      'telefono': telefono.isEmpty ? null : telefono,
    });
  }

  @override
  Future<Distribuidor> guardarTema(String distribuidorId, ConfigTema tema) {
    return _actualizar(distribuidorId, {'config_tema': tema.toJson()});
  }

  /// Un `update` que la política no permite no da error: no cambia ninguna
  /// fila. Por eso se pide la fila de vuelta.
  Future<Distribuidor> _actualizar(
    String distribuidorId,
    Map<String, Object?> columnas,
  ) {
    return _intentar(() async {
      final filas = await _cliente
          .from('distribuidores')
          .update(columnas)
          .eq('id', distribuidorId)
          .select();
      if (filas.isEmpty) {
        throw const ErrorConfiguracion(MotivoErrorConfiguracion.sinPermiso);
      }
      return Distribuidor.fromJson(filas.first);
    });
  }

  @override
  Future<String> subirLogo(
    String distribuidorId,
    Uint8List bytes,
    TipoImagen tipo,
  ) {
    return _intentar(() async {
      final ruta =
          '${carpetaLogo(distribuidorId)}'
          'logo-${_reloj().millisecondsSinceEpoch}.${tipo.extension}';
      final almacen = _cliente.storage.from(_bucket);
      await almacen.uploadBinary(
        ruta,
        bytes,
        fileOptions: FileOptions(contentType: tipo.mime, cacheControl: '3600'),
      );
      return almacen.getPublicUrl(ruta);
    });
  }

  @override
  Future<void> borrarArchivo(String ruta) {
    return _intentar(() => _cliente.storage.from(_bucket).remove([ruta]));
  }

  @override
  Future<List<PlanVigente>> listarSuscripciones(String distribuidorId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('suscripciones')
          .select('*, plan:planes(*)')
          .eq('distribuidor_id', distribuidorId);
      return [
        for (final fila in filas)
          if (fila['plan'] case final Map<String, dynamic> plan)
            PlanVigente(
              suscripcion: Suscripcion.fromJson(fila),
              plan: Plan.fromJson(plan),
            ),
      ];
    });
  }

  Future<T> _intentar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on ErrorConfiguracion {
      rethrow;
    } on PostgrestException catch (e, st) {
      _registrar(e, st);
      throw ErrorConfiguracion(switch (e.code) {
        '42501' => MotivoErrorConfiguracion.sinPermiso,
        '22023' || '23514' || '23502' => MotivoErrorConfiguracion.datoInvalido,
        _ => MotivoErrorConfiguracion.desconocido,
      });
    } on StorageException catch (e, st) {
      _registrar(e, st);
      throw ErrorConfiguracion(switch (e.statusCode) {
        '401' || '403' => MotivoErrorConfiguracion.sinPermiso,
        '400' || '413' || '415' => MotivoErrorConfiguracion.datoInvalido,
        _ => MotivoErrorConfiguracion.desconocido,
      });
    } catch (e, st) {
      _registrar(e, st);
      throw const ErrorConfiguracion(MotivoErrorConfiguracion.desconocido);
    }
  }

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'Falló una operación de configuración.',
      name: 'configuracion',
      error: error,
      stackTrace: pila,
    );
  }
}
