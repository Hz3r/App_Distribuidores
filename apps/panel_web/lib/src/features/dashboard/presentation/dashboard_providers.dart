import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../clientes/presentation/clientes_providers.dart';
import '../../pedidos/presentation/pedidos_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/resumen_ventas.dart';

part 'dashboard_providers.g.dart';

/// Lo que el Dashboard saca de los pedidos: los indicadores y los últimos
/// pedidos.
typedef DatosDashboard = ({ResumenVentas resumen, List<Pedido> recientes});

/// Indicadores del distribuidor activo, calculados con los pedidos desde el
/// día 1 del mes anterior. Se vuelve a leer cada vez que se abre el
/// Dashboard.
@riverpod
Future<DatosDashboard> datosDashboard(Ref ref) async {
  final ahora = ref.watch(relojProvider)();
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) {
    return (
      resumen: resumirVentas(const [], ahora),
      recientes: const <Pedido>[],
    );
  }
  final pedidos = await ref
      .watch(pedidosRepositorioProvider)
      .listarPedidosDesde(membresia.distribuidorId, inicioDelResumen(ahora));
  return (
    resumen: resumirVentas(pedidos, ahora),
    recientes: pedidos.take(5).toList(),
  );
}
