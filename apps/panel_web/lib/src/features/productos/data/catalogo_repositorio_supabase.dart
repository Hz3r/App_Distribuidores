import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalogo_repositorio.dart';

/// [CatalogoRepositorio] sobre Supabase. Manda solo las columnas que el
/// contrato deja escribir (sección 2, "Grants por columna") y traduce los
/// errores de Postgres a [ErrorCatalogo].
class CatalogoRepositorioSupabase implements CatalogoRepositorio {
  CatalogoRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Categoria>> listarCategorias(String distribuidorId) {
    return _intentar(() async {
      // `order` de supabase-dart ordena de mayor a menor si no se le dice.
      final filas = await _cliente
          .from('categorias')
          .select()
          .eq('distribuidor_id', distribuidorId)
          .order('orden', ascending: true)
          .order('nombre', ascending: true);
      return filas.map(Categoria.fromJson).toList();
    });
  }

  @override
  Future<List<Producto>> listarProductos(String distribuidorId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('productos')
          .select('*, presentaciones(*, precios_volumen(*))')
          .eq('distribuidor_id', distribuidorId)
          .order('nombre', ascending: true);
      return [
        for (final fila in filas)
          _ordenarPresentaciones(Producto.fromJson(fila)),
      ];
    });
  }

  @override
  Future<Categoria> crearCategoria(String distribuidorId, String nombre) {
    return _intentar(() async {
      final fila = await _cliente
          .from('categorias')
          .insert({'distribuidor_id': distribuidorId, 'nombre': nombre})
          .select()
          .single();
      return Categoria.fromJson(fila);
    });
  }

  @override
  Future<String> crearProducto(String distribuidorId, DatosProducto datos) {
    return _intentar(() async {
      final fila = await _cliente
          .from('productos')
          .insert({'distribuidor_id': distribuidorId, ..._columnas(datos)})
          .select('id')
          .single();
      return fila['id'] as String;
    });
  }

  @override
  Future<void> actualizarProducto(String productoId, DatosProducto datos) {
    return _actualizar('productos', productoId, _columnas(datos));
  }

  @override
  Future<void> cambiarActivoProducto(
    String productoId, {
    required bool activo,
  }) {
    return _actualizar('productos', productoId, {'activo': activo});
  }

  @override
  Future<void> crearPresentacion({
    required String distribuidorId,
    required String productoId,
    required DatosPresentacion datos,
    required int orden,
  }) {
    return _intentar(() async {
      await _cliente.from('presentaciones').insert({
        'distribuidor_id': distribuidorId,
        'producto_id': productoId,
        ..._columnasPresentacion(datos, orden),
      });
    });
  }

  @override
  Future<void> actualizarPresentacion(DatosPresentacion datos, int orden) {
    final id = datos.id;
    if (id == null) {
      throw ArgumentError('La presentación a actualizar no tiene id.');
    }
    return _actualizar(
      'presentaciones',
      id,
      _columnasPresentacion(datos, orden),
    );
  }

  @override
  Future<void> registrarMovimiento({
    required String productoId,
    required TipoMovimientoStock tipo,
    required int cantidad,
    String? nota,
  }) {
    return _intentar(() async {
      await _cliente.rpc<void>(
        'registrar_movimiento_stock',
        params: {
          'p_producto_id': productoId,
          'p_tipo': tipo.name,
          'p_cantidad': cantidad,
          'p_nota': nota,
        },
      );
    });
  }

  /// Un `update` que la política no permite no da error: no cambia ninguna
  /// fila. Por eso se pide el id de vuelta y, si no viene, es falta de permiso.
  Future<void> _actualizar(
    String tabla,
    String id,
    Map<String, Object?> valores,
  ) {
    return _intentar(() async {
      final filas = await _cliente
          .from(tabla)
          .update(valores)
          .eq('id', id)
          .select('id');
      if (filas.isEmpty) {
        throw const ErrorCatalogo(MotivoErrorCatalogo.sinPermiso);
      }
    });
  }

  Map<String, Object?> _columnas(DatosProducto datos) => {
    'categoria_id': datos.categoriaId,
    'nombre': datos.nombre,
    'descripcion': _oNulo(datos.descripcion),
    'marca': _oNulo(datos.marca),
    // La BD exige SKU nulo o no vacío.
    'sku': _oNulo(datos.sku),
    'unidad_base': datos.unidadBase,
    'activo': datos.activo,
  };

  Map<String, Object?> _columnasPresentacion(
    DatosPresentacion datos,
    int orden,
  ) => {
    'nombre': datos.nombre,
    'factor': datos.factor,
    'precio_base_centimos': datos.precioBaseCentimos,
    'orden': orden,
    'activo': datos.activo,
  };

  String? _oNulo(String? texto) {
    final limpio = texto?.trim() ?? '';
    return limpio.isEmpty ? null : limpio;
  }

  Producto _ordenarPresentaciones(Producto producto) {
    final ordenadas = [...producto.presentaciones]
      ..sort((a, b) {
        final porOrden = a.orden.compareTo(b.orden);
        return porOrden != 0 ? porOrden : a.factor.compareTo(b.factor);
      });
    return producto.copyWith(presentaciones: ordenadas);
  }

  Future<T> _intentar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on ErrorCatalogo {
      rethrow;
    } on PostgrestException catch (e, st) {
      final motivo = switch (e.code) {
        '23505' => MotivoErrorCatalogo.skuRepetido,
        'P0001' => MotivoErrorCatalogo.stockBajoReservado,
        '42501' => MotivoErrorCatalogo.sinPermiso,
        '22023' || '23514' || '23502' => MotivoErrorCatalogo.datoInvalido,
        _ => MotivoErrorCatalogo.desconocido,
      };
      _registrar(e, st);
      throw ErrorCatalogo(motivo);
    } catch (e, st) {
      _registrar(e, st);
      throw const ErrorCatalogo(MotivoErrorCatalogo.desconocido);
    }
  }

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'Falló una operación del catálogo.',
      name: 'catalogo',
      error: error,
      stackTrace: pila,
    );
  }
}
