import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../pedidos/presentation/pedidos_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../data/exportador_archivos.dart';
import '../domain/exportador.dart';
import '../domain/periodo.dart';

part 'reportes_providers.g.dart';

/// Exportador inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.
@Riverpod(keepAlive: true)
Exportador exportador(Ref ref) => ExportadorArchivos();

/// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
/// usan el reporte en pantalla y la exportación a Excel, así los dos
/// muestran exactamente lo mismo.
@riverpod
Future<List<Pedido>> pedidosDelPeriodo(Ref ref, Periodo periodo) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(pedidosRepositorioProvider)
      .listarPedidosEntre(
        membresia.distribuidorId,
        periodo.desde,
        periodo.hasta,
      );
}
