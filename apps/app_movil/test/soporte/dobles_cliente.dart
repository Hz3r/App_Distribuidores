import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/inicio/domain/pedidos_resumen_repositorio.dart';
import 'package:core/core.dart';

/// Dobles de los repositorios de la zona de la bodega (catálogo y pedidos
/// del inicio). Sin dependencias de otros ayudantes de prueba: los usan
/// tanto `montarCliente` como `montarApp`.

/// Doble de [CatalogoRepositorio]: devuelve [catalogo], o lanza [error] si
/// no es null. Cuenta las cargas.
class CatalogoRepositorioFijo implements CatalogoRepositorio {
  CatalogoRepositorioFijo(this.catalogo);

  Catalogo catalogo;
  Object? error;
  int cargas = 0;

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
  }) async {
    cargas++;
    final fallo = error;
    if (fallo != null) throw fallo;
    return catalogo;
  }
}

/// Doble de [PedidosResumenRepositorio]: devuelve [pedidos] como los
/// recientes y [ultimoFijo] como el último pedido (si es null, el más reciente
/// de [pedidos]); o lanza [error] si no es null. Anota cada lectura.
class PedidosResumenRepositorioFijo implements PedidosResumenRepositorio {
  PedidosResumenRepositorioFijo([this.pedidos = const []]);

  List<Pedido> pedidos;

  /// Último pedido, aunque no esté entre los recientes (más de 90 días).
  Pedido? ultimoFijo;
  Object? error;
  final lecturas =
      <({String distribuidorId, String clienteId, DateTime desde})>[];
  final lecturasUltimo = <({String distribuidorId, String clienteId})>[];

  @override
  Future<List<Pedido>> recientes({
    required String distribuidorId,
    required String clienteId,
    required DateTime desde,
  }) async {
    lecturas.add((
      distribuidorId: distribuidorId,
      clienteId: clienteId,
      desde: desde,
    ));
    final fallo = error;
    if (fallo != null) throw fallo;
    return pedidos;
  }

  @override
  Future<Pedido?> ultimo({
    required String distribuidorId,
    required String clienteId,
  }) async {
    lecturasUltimo.add((distribuidorId: distribuidorId, clienteId: clienteId));
    final fallo = error;
    if (fallo != null) throw fallo;
    if (ultimoFijo case final fijo?) return fijo;
    final porFecha = [...pedidos]
      ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    return porFecha.firstOrNull;
  }
}
