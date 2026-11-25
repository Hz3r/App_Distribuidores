import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/control_acceso.dart';
import '../data/catalogo_repositorio_supabase.dart';
import '../domain/catalogo_repositorio.dart';
import '../domain/guardar_producto.dart' as dominio;

part 'catalogo_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.
@Riverpod(keepAlive: true)
CatalogoRepositorio catalogoRepositorio(Ref ref) =>
    CatalogoRepositorioSupabase(supabase);

/// Categorías del distribuidor activo.
@riverpod
Future<List<Categoria>> categorias(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(catalogoRepositorioProvider)
      .listarCategorias(membresia.distribuidorId);
}

/// Productos del distribuidor activo, con sus presentaciones. Lo comparten
/// Productos y Disponibilidad.
@riverpod
Future<List<Producto>> productos(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(catalogoRepositorioProvider)
      .listarProductos(membresia.distribuidorId);
}

/// Escrituras del catálogo. Cada una vuelve a leer lo que cambió. Lanzan
/// [ErrorCatalogo]; la pantalla lo convierte en mensaje con [mensajeDe].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.
@Riverpod(keepAlive: true)
AccionesCatalogo accionesCatalogo(Ref ref) => AccionesCatalogo(ref);

class AccionesCatalogo {
  AccionesCatalogo(this._ref);

  final Ref _ref;

  CatalogoRepositorio get _repositorio =>
      _ref.read(catalogoRepositorioProvider);

  String get _distribuidorId {
    final membresia = _ref.read(membresiaActivaProvider);
    if (membresia == null) {
      throw const ErrorCatalogo(MotivoErrorCatalogo.sinPermiso);
    }
    return membresia.distribuidorId;
  }

  Future<Categoria> crearCategoria(String nombre) async {
    final categoria = await _repositorio.crearCategoria(
      _distribuidorId,
      nombre.trim(),
    );
    _ref.invalidate(categoriasProvider);
    return categoria;
  }

  Future<void> guardarProducto({
    required DatosProducto datos,
    required List<DatosPresentacion> presentaciones,
    Producto? original,
    int disponibilidadInicial = 0,
  }) async {
    try {
      await dominio.guardarProducto(
        _repositorio,
        distribuidorId: _distribuidorId,
        datos: datos,
        presentaciones: presentaciones,
        original: original,
        disponibilidadInicial: disponibilidadInicial,
      );
    } finally {
      // También si falló a mitad: parte pudo haberse guardado.
      _ref.invalidate(productosProvider);
    }
  }

  Future<void> cambiarVisible(
    Producto producto, {
    required bool visible,
  }) async {
    await _repositorio.cambiarActivoProducto(producto.id, activo: visible);
    _ref.invalidate(productosProvider);
  }

  Future<void> registrarMovimiento({
    required String productoId,
    required TipoMovimientoStock tipo,
    required int cantidad,
    String? nota,
  }) async {
    await _repositorio.registrarMovimiento(
      productoId: productoId,
      tipo: tipo,
      cantidad: cantidad,
      nota: nota,
    );
    _ref.invalidate(productosProvider);
  }
}

/// Mensaje para la persona según por qué falló la operación.
String mensajeDe(Object error) {
  final motivo = error is ErrorCatalogo
      ? error.motivo
      : MotivoErrorCatalogo.desconocido;
  return switch (motivo) {
    MotivoErrorCatalogo.skuRepetido =>
      'Ya tienes otro producto con ese SKU. Usa uno distinto.',
    MotivoErrorCatalogo.stockBajoReservado =>
      'No puedes dejar menos de lo que ya está reservado en pedidos.',
    MotivoErrorCatalogo.sinPermiso =>
      'Tu cuenta no puede hacer este cambio. Pídeselo al administrador.',
    MotivoErrorCatalogo.datoInvalido =>
      'Hay un dato que no es válido. Revísalo e inténtalo de nuevo.',
    MotivoErrorCatalogo.desconocido =>
      'No pudimos guardar. Revisa tu conexión e inténtalo de nuevo.',
  };
}
