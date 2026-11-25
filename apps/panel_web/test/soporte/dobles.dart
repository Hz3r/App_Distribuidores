import 'dart:async';

import 'package:core/core.dart';
import 'package:panel_web/src/features/productos/domain/catalogo_repositorio.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';
import 'package:panel_web/src/features/sesion/domain/autenticacion.dart';
import 'package:panel_web/src/features/sesion/domain/membresias_repositorio.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';

/// Membresía con su distribuidor embebido. Por defecto, admin activo.
Membresia membresia(
  String distribuidorId, {
  RolMembresia rol = RolMembresia.admin,
  EstadoMembresia estado = EstadoMembresia.activa,
  EstadoDistribuidor estadoDistribuidor = EstadoDistribuidor.activo,
  bool conDistribuidor = true,
}) {
  return Membresia(
    id: 'm-$distribuidorId-${rol.name}',
    perfilId: 'p1',
    distribuidorId: distribuidorId,
    rol: rol,
    estado: estado,
    creadoEn: DateTime.utc(2026),
    distribuidor: conDistribuidor
        ? Distribuidor(
            id: distribuidorId,
            nombre: 'Distribuidor $distribuidorId',
            slug: distribuidorId,
            estado: estadoDistribuidor,
            moneda: 'PEN',
            zonaHoraria: 'America/Lima',
            configTema: const ConfigTema(),
            creadoEn: DateTime.utc(2026),
          )
        : null,
  );
}

/// Acceso con una sola membresía, ya activa.
ConAcceso accesoCon(Membresia m) => ConAcceso(membresias: [m], activa: m);

/// Doble de [MembresiasRepositorio]. Si [respuesta] es un `Completer`, la
/// lectura queda pendiente hasta que la prueba lo complete.
class RepositorioDoble implements MembresiasRepositorio {
  List<Membresia> membresias = [];
  String? preferido;
  Object? error;
  Completer<List<Membresia>>? respuesta;
  final guardados = <String>[];
  int lecturas = 0;

  @override
  Future<List<Membresia>> listarMias() async {
    lecturas++;
    final pendiente = respuesta;
    if (pendiente != null) return pendiente.future;
    final fallo = error;
    if (fallo != null) throw fallo;
    return membresias;
  }

  @override
  String? distribuidorPreferido() => preferido;

  @override
  Future<void> guardarDistribuidorPreferido(String distribuidorId) async {
    guardados.add(distribuidorId);
    preferido = distribuidorId;
  }
}

/// Doble de [Autenticacion]: devuelve [resultado] y registra las llamadas.
class AutenticacionDoble implements Autenticacion {
  AutenticacionDoble({
    this.resultado = ResultadoIngreso.ok,
    this.correoActual = 'admin@ejemplo.com',
    this.errorAlCerrar,
  });

  ResultadoIngreso resultado;
  Object? errorAlCerrar;
  final ingresos = <({String correo, String contrasena})>[];
  int cierres = 0;

  @override
  String? correoActual;

  @override
  Future<ResultadoIngreso> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    ingresos.add((correo: correo, contrasena: contrasena));
    return resultado;
  }

  @override
  Future<void> cerrarSesion() async {
    cierres++;
    final fallo = errorAlCerrar;
    if (fallo != null) throw fallo;
  }
}

/// Controlador falso: parte de un acceso fijo y cuenta las llamadas. No toca
/// `Supabase.instance`.
class ControlAccesoFalso extends ControlAcceso {
  ControlAccesoFalso(this.inicial, {this.cierreOk = true});

  final Acceso inicial;
  final bool cierreOk;
  int recargas = 0;
  int cierres = 0;
  final elegidos = <String>[];

  @override
  Acceso build() => inicial;

  @override
  Future<void> recargar() async => recargas++;

  @override
  Future<void> elegirDistribuidor(String distribuidorId) async {
    elegidos.add(distribuidorId);
    final actual = state;
    if (actual is! ConAcceso) return;
    state = ConAcceso(
      membresias: actual.membresias,
      activa: actual.membresias.firstWhere(
        (m) => m.distribuidorId == distribuidorId,
      ),
    );
  }

  @override
  Future<bool> cerrarSesion() async {
    cierres++;
    return cierreOk;
  }
}

/// Producto de prueba del distribuidor `d1`.
Producto producto(
  String id, {
  String? nombre,
  String? categoriaId,
  String? marca,
  String? sku,
  String unidadBase = 'botella',
  int fisico = 100,
  int comprometido = 0,
  bool activo = true,
  List<Presentacion> presentaciones = const [],
}) {
  return Producto(
    id: id,
    distribuidorId: 'd1',
    categoriaId: categoriaId,
    nombre: nombre ?? 'Producto $id',
    marca: marca,
    sku: sku,
    unidadBase: unidadBase,
    stockFisico: fisico,
    stockComprometido: comprometido,
    activo: activo,
    creadoEn: DateTime.utc(2026),
    presentaciones: presentaciones,
  );
}

Presentacion presentacion(
  String id, {
  String productoId = 'p1',
  String nombre = 'Botella',
  int factor = 1,
  int precio = 850,
  int orden = 0,
  bool activo = true,
}) {
  return Presentacion(
    id: id,
    distribuidorId: 'd1',
    productoId: productoId,
    nombre: nombre,
    factor: factor,
    precioBaseCentimos: precio,
    orden: orden,
    activo: activo,
    creadoEn: DateTime.utc(2026),
  );
}

Categoria categoria(String id, String nombre) => Categoria(
  id: id,
  distribuidorId: 'd1',
  nombre: nombre,
  orden: 0,
  activo: true,
  creadoEn: DateTime.utc(2026),
);

/// Doble de [CatalogoRepositorio]: devuelve listas fijas y anota cada
/// escritura en [llamadas], en orden. [fallarEn] hace fallar la operación
/// con ese nombre.
class CatalogoDoble implements CatalogoRepositorio {
  CatalogoDoble({List<Producto>? productos, List<Categoria>? categorias})
    : productos = productos ?? [],
      categorias = categorias ?? [];

  List<Producto> productos;
  List<Categoria> categorias;
  final llamadas = <String>[];
  String? fallarEn;
  MotivoErrorCatalogo motivo = MotivoErrorCatalogo.desconocido;
  int lecturasProductos = 0;

  void _anotar(String operacion, String detalle) {
    if (fallarEn == operacion) throw ErrorCatalogo(motivo);
    llamadas.add('$operacion $detalle');
  }

  @override
  Future<List<Categoria>> listarCategorias(String distribuidorId) async =>
      categorias;

  @override
  Future<List<Producto>> listarProductos(String distribuidorId) async {
    lecturasProductos++;
    if (fallarEn == 'listarProductos') throw ErrorCatalogo(motivo);
    return productos;
  }

  @override
  Future<Categoria> crearCategoria(String distribuidorId, String nombre) async {
    _anotar('crearCategoria', nombre);
    final nueva = categoria('c-nueva', nombre);
    categorias = [...categorias, nueva];
    return nueva;
  }

  @override
  Future<String> crearProducto(
    String distribuidorId,
    DatosProducto datos,
  ) async {
    _anotar(
      'crearProducto',
      '$distribuidorId ${datos.nombre} unidad=${datos.unidadBase} '
          'categoria=${datos.categoriaId} activo=${datos.activo}',
    );
    return 'p-nuevo';
  }

  @override
  Future<void> actualizarProducto(
    String productoId,
    DatosProducto datos,
  ) async {
    _anotar('actualizarProducto', '$productoId ${datos.nombre}');
  }

  @override
  Future<void> cambiarActivoProducto(
    String productoId, {
    required bool activo,
  }) async {
    _anotar('cambiarActivoProducto', '$productoId $activo');
  }

  @override
  Future<void> crearPresentacion({
    required String distribuidorId,
    required String productoId,
    required DatosPresentacion datos,
    required int orden,
  }) async {
    _anotar(
      'crearPresentacion',
      '$productoId ${datos.nombre} x${datos.factor} '
          '${datos.precioBaseCentimos} orden=$orden',
    );
  }

  @override
  Future<void> actualizarPresentacion(
    DatosPresentacion datos,
    int orden,
  ) async {
    _anotar(
      'actualizarPresentacion',
      '${datos.id} ${datos.nombre} x${datos.factor} '
          '${datos.precioBaseCentimos} activo=${datos.activo} orden=$orden',
    );
  }

  @override
  Future<void> registrarMovimiento({
    required String productoId,
    required TipoMovimientoStock tipo,
    required int cantidad,
    String? nota,
  }) async {
    _anotar('registrarMovimiento', '$productoId ${tipo.name} $cantidad $nota');
  }
}
