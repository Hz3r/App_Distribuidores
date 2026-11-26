import 'package:core/core.dart';

/// Constructores auxiliares de modelos del catálogo para las pruebas.

final _creado = DateTime.utc(2026);

PrecioVolumen volumen(int cantidadMinima, int precioCentimos) => PrecioVolumen(
  id: 'v-$cantidadMinima-$precioCentimos',
  distribuidorId: 'd1',
  presentacionId: 'pr',
  cantidadMinima: cantidadMinima,
  precioCentimos: precioCentimos,
  creadoEn: _creado,
);

Presentacion presentacion(
  String id, {
  String productoId = 'p',
  String? nombre,
  int factor = 1,
  int precioBase = 6290,
  int orden = 0,
  bool activo = true,
  List<PrecioVolumen> preciosVolumen = const [],
}) => Presentacion(
  id: id,
  distribuidorId: 'd1',
  productoId: productoId,
  nombre: nombre ?? 'Presentación $id',
  factor: factor,
  precioBaseCentimos: precioBase,
  orden: orden,
  activo: activo,
  creadoEn: _creado,
  preciosVolumen: preciosVolumen,
);

Producto producto(
  String id, {
  String? nombre,
  String? marca,
  String? categoriaId = 'c1',
  int stockFisico = 120,
  int stockComprometido = 0,
  bool activo = true,
  List<Presentacion>? presentaciones,
}) => Producto(
  id: id,
  distribuidorId: 'd1',
  categoriaId: categoriaId,
  nombre: nombre ?? 'Producto $id',
  marca: marca,
  unidadBase: 'botella',
  stockFisico: stockFisico,
  stockComprometido: stockComprometido,
  activo: activo,
  creadoEn: _creado,
  presentaciones: presentaciones ?? [presentacion('$id-u', productoId: id)],
);

Categoria categoria(
  String id, {
  String? nombre,
  int orden = 0,
  bool activo = true,
}) => Categoria(
  id: id,
  distribuidorId: 'd1',
  nombre: nombre ?? 'Categoría $id',
  orden: orden,
  activo: activo,
  creadoEn: _creado,
);
