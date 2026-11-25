import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../disponibilidad/domain/disponibilidad.dart';
import '../../pedidos/presentation/pedido_detalle.dart';
import '../../productos/presentation/catalogo_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/resumen_ventas.dart';
import 'dashboard_providers.dart';
import 'grafico_ventas.dart';

/// Resumen del negocio: ventas del mes, lo que hay que atender hoy, los
/// mejores clientes y los productos que se están quedando sin disponibilidad.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consulta = ref.watch(datosDashboardProvider);
    final ahora = ref.watch(relojProvider)().toLocal();
    final negocio = ref
        .watch(membresiaActivaProvider)
        ?.distribuidor
        ?.nombreVisible;
    final datos = consulta.value;

    final Widget cuerpo;
    if (datos == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(datosDashboardProvider),
            )
          : const EstadoCarga();
    } else {
      cuerpo = _Contenido(datos: datos, ahora: ahora);
    }

    return PaginaPanel(
      titulo: 'Dashboard',
      descripcion: negocio == null
          ? 'Hoy es ${fechaLarga(ahora)}.'
          : '$negocio · ${fechaLarga(ahora)}.',
      acciones: [
        IconButton(
          tooltip: 'Actualizar el resumen',
          onPressed: () => ref.invalidate(datosDashboardProvider),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: cuerpo,
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.datos, required this.ahora});

  final DatosDashboard datos;
  final DateTime ahora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = datos.resumen;
    final clientes =
        ref.watch(clientesProvider).value ?? const <ClienteNegocio>[];
    final productos = ref.watch(productosProvider).value ?? const <Producto>[];
    final nombreCliente = {for (final c in clientes) c.id: c.nombreNegocio};
    final clientesActivos = clientes.where((c) => c.activo).length;
    final agotados = [
      for (final p in productos)
        if (p.activo && nivelDe(p) == NivelDisponibilidad.agotado) p,
    ];
    final bajos = [
      for (final p in productos)
        if (p.activo && nivelDe(p) == NivelDisponibilidad.bajo) p,
    ];

    void ir(String ruta) => GoRouter.maybeOf(context)?.go(ruta);

    final mesAnterior = nombreMes(DateTime(ahora.year, ahora.month - 1).month);
    final variacion = variacionPorcentual(
      resumen.ventasMesCentimos,
      resumen.ventasMesAnteriorCentimos,
    );

    final indicadores = [
      _Indicador(
        etiqueta: 'Ventas de ${nombreMes(ahora.month)}',
        valor: resumen.ventasMesCentimos.formatoSoles,
        icono: Icons.trending_up_rounded,
        detalle: _Variacion(variacion: variacion, mesAnterior: mesAnterior),
      ),
      _Indicador(
        etiqueta: 'Pedidos por confirmar',
        valor: '${resumen.porConfirmar}',
        icono: Icons.receipt_long_outlined,
        tono: resumen.porConfirmar > 0 ? TonoEtiqueta.aviso : TonoEtiqueta.info,
        detalle: Text(
          resumen.porConfirmar == 0
              ? 'Estás al día.'
              : resumen.llegaronHoy == 1
              ? '1 llegó hoy. Toca para atenderlos.'
              : '${resumen.llegaronHoy} llegaron hoy. Toca para atenderlos.',
        ),
        alTocar: () => ir(AppRutas.pedidos),
      ),
      _Indicador(
        etiqueta: 'Clientes que compraron',
        valor: '${resumen.clientesQueCompraron} de $clientesActivos',
        icono: Icons.storefront_outlined,
        detalle: Text(
          resumen.pedidosMes == 1
              ? '1 pedido este mes.'
              : '${resumen.pedidosMes} pedidos este mes.',
        ),
        alTocar: () => ir(AppRutas.clientes),
      ),
      _Indicador(
        etiqueta: 'Productos agotados',
        valor: '${agotados.length}',
        icono: Icons.inventory_2_outlined,
        tono: agotados.isEmpty ? TonoEtiqueta.info : TonoEtiqueta.peligro,
        detalle: Text(
          bajos.isEmpty
              ? 'Ninguno con poca disponibilidad.'
              : bajos.length == 1
              ? '1 más con poca disponibilidad.'
              : '${bajos.length} más con poca disponibilidad.',
        ),
        alTocar: () => ir(AppRutas.disponibilidad),
      ),
    ];

    return LayoutBuilder(
      builder: (context, limites) {
        final ancho = limites.maxWidth;
        final columnas = ancho >= 960
            ? 4
            : ancho >= 520
            ? 2
            : 1;
        const hueco = 16.0;
        final anchoTarjeta = (ancho - hueco * (columnas - 1)) / columnas;
        final dosColumnas = ancho >= 860;

        final ventas = _Tarjeta(
          titulo: 'Ventas de los últimos 7 días',
          child: resumen.ventasUltimosDiasCentimos == 0
              ? const _SinDatos('Todavía no hay ventas en estos 7 días.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumen.ventasUltimosDiasCentimos.formatoSoles,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ColoresPanel.neutro900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GraficoVentas(dias: resumen.ultimosDias, hoy: ahora),
                  ],
                ),
        );
        final top = _Tarjeta(
          titulo: 'Quién compró más en ${nombreMes(ahora.month)}',
          child: resumen.topClientes.isEmpty
              ? const _SinDatos('Aún no hay ventas este mes.')
              : Column(
                  children: [
                    for (final venta in resumen.topClientes)
                      _FilaCliente(
                        nombre: nombreCliente[venta.clienteId] ?? 'Cliente',
                        venta: venta,
                        maximo: resumen.topClientes.first.centimos,
                      ),
                  ],
                ),
        );
        final recientes = _Tarjeta(
          titulo: 'Últimos pedidos',
          accion: datos.recientes.isEmpty
              ? null
              : TextButton(
                  onPressed: () => ir(AppRutas.pedidos),
                  child: const Text('Ver todos'),
                ),
          child: datos.recientes.isEmpty
              ? const _SinDatos(
                  'Cuando tus clientes pidan, sus pedidos aparecen aquí.',
                )
              : Column(
                  children: [
                    for (final pedido in datos.recientes)
                      _FilaPedido(
                        pedido: pedido,
                        cliente: nombreCliente[pedido.clienteId] ?? 'Cliente',
                      ),
                  ],
                ),
        );
        final disponibilidad = _Tarjeta(
          titulo: 'Se están acabando',
          accion: agotados.isEmpty && bajos.isEmpty
              ? null
              : TextButton(
                  onPressed: () => ir(AppRutas.disponibilidad),
                  child: const Text('Actualizar'),
                ),
          child: agotados.isEmpty && bajos.isEmpty
              ? const _SinDatos('Todos tus productos tienen disponibilidad.')
              : Column(
                  children: [
                    for (final producto in [...agotados, ...bajos].take(5))
                      _FilaProducto(producto),
                  ],
                ),
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: hueco,
                runSpacing: hueco,
                children: [
                  for (final indicador in indicadores)
                    SizedBox(width: anchoTarjeta, child: indicador),
                ],
              ),
              const SizedBox(height: hueco),
              if (dosColumnas) ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: ventas),
                      const SizedBox(width: hueco),
                      Expanded(flex: 2, child: top),
                    ],
                  ),
                ),
                const SizedBox(height: hueco),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: recientes),
                      const SizedBox(width: hueco),
                      Expanded(flex: 2, child: disponibilidad),
                    ],
                  ),
                ),
              ] else ...[
                ventas,
                const SizedBox(height: hueco),
                top,
                const SizedBox(height: hueco),
                recientes,
                const SizedBox(height: hueco),
                disponibilidad,
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta con un número grande. Si se puede tocar, lleva a la sección
/// donde se atiende ese número.
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.detalle,
    this.tono = TonoEtiqueta.info,
    this.alTocar,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;
  final Widget detalle;
  final TonoEtiqueta tono;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresPanel.blanco,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresPanel.neutro200),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: tono.fondo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(icono, size: 20, color: tono.texto),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      etiqueta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColoresPanel.neutro500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 30 / 24,
                    fontWeight: FontWeight.w700,
                    color: ColoresPanel.neutro900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresPanel.neutro500,
                ),
                child: detalle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Comparación con los mismos días del mes anterior: flecha, porcentaje y
/// con qué se compara (nunca solo el color).
class _Variacion extends StatelessWidget {
  const _Variacion({required this.variacion, required this.mesAnterior});

  final int? variacion;
  final String mesAnterior;

  @override
  Widget build(BuildContext context) {
    final variacion = this.variacion;
    if (variacion == null) {
      return Text('Sin ventas en $mesAnterior para comparar.');
    }
    if (variacion == 0) {
      return Text('Igual que en los mismos días de $mesAnterior.');
    }
    final sube = variacion > 0;
    final color = sube ? ColoresPanel.exito500 : ColoresPanel.peligro500;
    return Row(
      children: [
        Icon(
          sube ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            '${variacion.abs()}% ${sube ? 'más' : 'menos'} que en los mismos '
            'días de $mesAnterior.',
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.child, this.accion});

  final String titulo;
  final Widget child;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final accion = this.accion;
    return Material(
      color: ColoresPanel.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresPanel.neutro200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ?accion,
                ],
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SinDatos extends StatelessWidget {
  const _SinDatos(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: const TextStyle(color: ColoresPanel.neutro500),
      ),
    );
  }
}

class _FilaCliente extends StatelessWidget {
  const _FilaCliente({
    required this.nombre,
    required this.venta,
    required this.maximo,
  });

  final String nombre;
  final VentaCliente venta;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColoresPanel.neutro900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                venta.centimos.formatoSoles,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColoresPanel.neutro900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: maximo <= 0 ? 0 : venta.centimos / maximo,
              minHeight: 6,
              color: ColoresPanel.primario500,
              backgroundColor: ColoresPanel.neutro100,
              semanticsLabel: 'Ventas a $nombre',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaPedido extends StatelessWidget {
  const _FilaPedido({required this.pedido, required this.cliente});

  final Pedido pedido;
  final String cliente;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${pedido.numero} · $cliente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColoresPanel.neutro900,
                  ),
                ),
                Text(
                  '${fechaHoraCorta(pedido.creadoEn)} · '
                  '${pedido.totalCentimos.formatoSoles}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresPanel.neutro500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Etiqueta(
            estadoPedidoLegible(pedido.estado),
            tono: tonoDeEstado(pedido.estado),
          ),
        ],
      ),
    );
  }
}

class _FilaProducto extends StatelessWidget {
  const _FilaProducto(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final agotado = producto.stockDisponible <= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              producto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ColoresPanel.neutro900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Etiqueta(
            agotado
                ? 'Agotado'
                : 'Quedan '
                      '${cantidadConUnidad(producto.stockDisponible, producto.unidadBase)}',
            tono: agotado ? TonoEtiqueta.peligro : TonoEtiqueta.aviso,
          ),
        ],
      ),
    );
  }
}
