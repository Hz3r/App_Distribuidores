import 'package:core/core.dart';

/// Datos editables de un producto (lo que el formulario manda a guardar).
class DatosProducto {
  const DatosProducto({
    required this.nombre,
    required this.unidadBase,
    this.categoriaId,
    this.marca,
    this.sku,
    this.descripcion,
    this.activo = true,
  });

  final String nombre;

  /// En qué se cuenta la disponibilidad: `botella`, `unidad`, `kg`...
  final String unidadBase;
  final String? categoriaId;
  final String? marca;
  final String? sku;
  final String? descripcion;
  final bool activo;
}

/// Datos editables de una presentación. [id] nulo = presentación nueva.
class DatosPresentacion {
  const DatosPresentacion({
    required this.nombre,
    required this.factor,
    required this.precioBaseCentimos,
    this.id,
    this.activo = true,
  });

  final String? id;
  final String nombre;

  /// Cuántas unidades base trae (una caja x12 → 12).
  final int factor;
  final int precioBaseCentimos;
  final bool activo;
}

/// Por qué falló una operación del catálogo. La pantalla decide el mensaje.
enum MotivoErrorCatalogo {
  /// Ya existe otro producto con ese SKU.
  skuRepetido,

  /// La nueva cantidad queda por debajo de lo reservado en pedidos.
  stockBajoReservado,

  /// El rol no puede hacer el cambio (por ejemplo, un vendedor).
  sinPermiso,

  /// Dato que la base de datos rechazó.
  datoInvalido,

  /// Red, servicio caído u otro fallo.
  desconocido,
}

class ErrorCatalogo implements Exception {
  const ErrorCatalogo(this.motivo);

  final MotivoErrorCatalogo motivo;

  @override
  String toString() => 'ErrorCatalogo(${motivo.name})';
}

/// Lectura y escritura del catálogo de un distribuidor. Las operaciones que
/// fallan lanzan [ErrorCatalogo].
abstract interface class CatalogoRepositorio {
  /// Categorías del distribuidor, por `orden` y nombre.
  Future<List<Categoria>> listarCategorias(String distribuidorId);

  /// Productos (activos o no) con sus presentaciones por `orden`.
  Future<List<Producto>> listarProductos(String distribuidorId);

  Future<Categoria> crearCategoria(String distribuidorId, String nombre);

  /// Devuelve el id del producto creado. Nace con disponibilidad 0.
  Future<String> crearProducto(String distribuidorId, DatosProducto datos);

  Future<void> actualizarProducto(String productoId, DatosProducto datos);

  /// Muestra u oculta el producto a los clientes.
  Future<void> cambiarActivoProducto(String productoId, {required bool activo});

  Future<void> crearPresentacion({
    required String distribuidorId,
    required String productoId,
    required DatosPresentacion datos,
    required int orden,
  });

  /// `datos.id` es obligatorio.
  Future<void> actualizarPresentacion(DatosPresentacion datos, int orden);

  /// `registrar_movimiento_stock`: `ingreso` (cantidad > 0) o `ajuste`
  /// (diferencia con signo, distinta de 0), en unidades base.
  Future<void> registrarMovimiento({
    required String productoId,
    required TipoMovimientoStock tipo,
    required int cantidad,
    String? nota,
  });
}
